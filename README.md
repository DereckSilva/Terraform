# Terraform Learn

Projeto de estudo com o intuito de aprender Terraform na prática.

O objetivo é criar uma infraestrutura simples na OCI (Oracle Cloud Infrastructure) para entender os conceitos básicos da ferramenta: providers, backend remoto de estado, variáveis e recursos e demais funcionalidades.

Não é um projeto de produção — é um laboratório pessoal de aprendizado.

## O que foi desenvolvido

### Configuração base

| Item | Detalhe |
|------|---------|
| Provider | `oracle/oci` versão `8.29.0`, autenticado pelo perfil `DEFAULT` do `~/.oci/config` |
| Backend remoto | Estado armazenado em bucket do Object Storage da OCI (`descomplicando-terraform-dereck`, região `sa-saopaulo-1`) |
| Região / AD | São Paulo — `SA-SAOPAULO-1-AD-1` |
| Variáveis | `ocid_compartment`, `availability_domain_sp`, `dhcp_options_id` e `ipLocal`, com blocos de `validation` |
| Refatoração | `moved.tf` com blocos `moved` para migrar os recursos criados na raiz para dentro dos módulos sem recriá-los |

### Módulos (`modules/`)

Toda a infraestrutura é orquestrada no `terrafile.tf`, que conecta os módulos passando os outputs de um como entrada do outro.

| Módulo | Recursos criados | Descrição |
|--------|------------------|-----------|
| `compartment` | `oci_identity_compartment` | Compartment `TerraformEstudos`, onde todos os demais recursos são criados |
| `tag` | `oci_identity_tag_namespace`, `oci_identity_tag` | Namespace `Governanca` com a tag `Ambiente` (valores permitidos: `Estudos`, `Homologação`) |
| `vcn` | `oci_core_vcn` | VCN `minhaVCN` com CIDR `10.0.0.0/16` |
| `gateway` | `oci_core_internet_gateway`, `oci_core_nat_gateway` | Internet Gateway (saída da subnet pública) e NAT Gateway (saída da subnet privada) |
| `routing` | `oci_core_route_table` (x2) | `RouteTablePublica` → Internet Gateway; `RouteTablePrivada` → NAT Gateway |
| `security` | `oci_core_security_list` (x2) | Security lists pública e privada (detalhes abaixo) |
| `subnets` | `oci_core_subnet` (x2, via `for_each`) | `TestSubNetPub` (`10.0.1.0/24`, com IP público) e `TestSubNetPriv` (`10.0.5.0/24`, sem IP público) |
| `network` | `oci_core_network_security_group` (x2, via `for_each`) | NSGs `nsg-publica` e `nsg-privada` |
| `network-rules` | `oci_core_network_security_group_security_rule` | Regra de egress TCP liberada para `0.0.0.0/0` na NSG privada (parcial) |
| `instances` | `oci_core_instance` (x2, via `for_each`) | Instâncias `instancia-front` e `instancia-back` (detalhes abaixo) |

### Instâncias de computação

Criadas pelo módulo `instances`, dentro do limite Always Free da OCI:

| Item | Detalhe |
|------|---------|
| Shape | `VM.Standard.E2.1.Micro` (AMD, 1/8 OCPU, 1 GB de RAM — até 2 instâncias no Always Free) |
| Imagem | Canonical Ubuntu 22.04, buscada via data source `oci_core_images` (imagem mais recente compatível com o shape) |
| Rede | Subnet privada `TestSubNetPriv`, sem IP público, associadas à NSG privada |
| Acesso | Chave pública SSH injetada via `metadata.ssh_authorized_keys`; acesso feito pelo Bastion (abaixo) |

### Bastion (`sessions/`)

O acesso SSH às instâncias da subnet privada é feito pelo **OCI Bastion Service** (sem custo), definido em um **root module separado** no diretório `sessions/`, com **state próprio** (`terraform-bastion.tfstate`, no mesmo bucket do backend principal).

| Item | Detalhe |
|------|---------|
| Recurso | `oci_bastion_bastion` do tipo `STANDARD` |
| Alvo | Subnet privada `TestSubNetPriv` |
| Origem permitida | Apenas o IP local (`ipLocal`) via `client_cidr_block_allow_list` |
| Duração máxima das sessões | 3 horas (`max_session_ttl_in_seconds = 10800`) |
| Dados da infra principal | Compartment e subnet buscados por nome via data sources (`oci_identity_compartments`, `oci_core_subnets`) |

As **sessões** do bastion (acesso temporário a cada instância) são efêmeras e não ficam no Terraform: são criadas sob demanda pela CLI da OCI (`oci bastion session create-port-forwarding ...`).

> [!IMPORTANT]
> Como o bastion está em outro state, ele deve ser destruído **antes** da infraestrutura principal (`cd sessions && terraform destroy`), pois a subnet privada não pode ser removida enquanto o bastion estiver ligado a ela.

### Topologia de rede

```
VCN minhaVCN (10.0.0.0/16)
├── TestSubNetPub  (10.0.1.0/24) ── RouteTablePublica ──► Internet Gateway
└── TestSubNetPriv (10.0.5.0/24) ── RouteTablePrivada ──► NAT Gateway
    ├── instancia-front
    ├── instancia-back
    └── endpoint do Bastion ◄── SSH a partir do IP local (ipLocal)
```

### Regras de segurança

**Security list pública**
- Ingress: SSH (22) de qualquer origem; ICMP (ping e Path MTU Discovery); API do Kubernetes (6443) a partir do IP local (`ipLocal`) e da subnet privada.
- Egress: SSH (22) para a subnet privada e todo o tráfego liberado para a internet.

**Security list privada**
- Ingress: todo o tráfego vindo da própria subnet privada; SSH (22), ICMP e kubelet (10250) vindos da subnet pública.
- Egress: todo o tráfego liberado (saída via NAT Gateway).

### Conceitos de Terraform praticados

- Providers e versionamento (`required_providers`, `versions.tf` por módulo)
- Backend remoto de estado no Object Storage da OCI
- Variáveis com `validation`, `locals` e `outputs`
- Modularização e passagem de dados entre módulos
- `for_each` para criar múltiplos recursos (subnets, NSGs e instâncias)
- Blocos `moved` para refatorar sem destruir recursos
- Data sources para buscar recursos existentes (imagens, compartment e subnet)
- Múltiplos states no mesmo backend (infra principal e bastion em root modules separados)
- Funções nativas (`substr()`, `contains()`)

> [!NOTE]
> **Kubernetes neste repositório: OKE x k3s**
>
> A proposta inicial era utilizar o gerenciamento da própria nuvem para o Kubernetes, através do **OKE (Oracle Container Engine for Kubernetes)**: a OCI cuidaria do control plane e os node pools seriam gerenciados pelo serviço.
>
> Porém, **por conta do limite do plano da conta na OCI, não foi possível implementar essa abordagem**, e o código do OKE foi removido do projeto.
>
> A alternativa considerada em seguida foi o **[k3s](https://k3s.io/)** em instâncias de computação da OCI, mas ela também não seguiu neste projeto: a capacidade das instâncias Always Free é limitada e a criação do shape `VM.Standard.A1.Flex` esbarrou em falta de capacidade na região.
>
> Este repositório continua focado no estudo de Terraform e da infraestrutura de rede/computação na OCI.

## Kubernetes (k3s) em outro repositório

O cluster k3s (com ArgoCD, plugins e observabilidade) será desenvolvido em um repositório separado, com uma infraestrutura própria e diferente desta.

> Repositório: [github.com/DereckSilva/Terraform-Local](https://github.com/DereckSilva/Terraform-Local)
