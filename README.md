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

### Topologia de rede

```
VCN minhaVCN (10.0.0.0/16)
├── TestSubNetPub  (10.0.1.0/24) ── RouteTablePublica ──► Internet Gateway
└── TestSubNetPriv (10.0.5.0/24) ── RouteTablePrivada ──► NAT Gateway
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
- `for_each` para criar múltiplos recursos (subnets e NSGs)
- Blocos `moved` para refatorar sem destruir recursos
- Funções nativas (`substr()`, `contains()`)

> [!NOTE]
> **Gerenciamento do cluster: OKE x k3s**
>
> A proposta inicial era utilizar o gerenciamento da própria nuvem para o Kubernetes, através do **OKE (Oracle Container Engine for Kubernetes)**: a OCI cuidaria do control plane e os node pools seriam gerenciados pelo serviço.
>
> Porém, **por conta do limite do plano da conta na OCI, não foi possível implementar essa abordagem**, e o código do OKE foi removido do projeto.
>
> A abordagem alternativa seria a utilização do **[k3s](https://k3s.io/)** diretamente em instâncias de computação da OCI (`oci_core_instance`), aproveitando a mesma rede já criada (VCN, subnets, gateways, route tables e security lists):
> - uma instância atuando como **server** (control plane do k3s);
> - uma ou mais instâncias atuando como **agents** (workers), ingressando no cluster pelo token do server;
> - o próprio cluster sendo gerenciado manualmente (instalação, upgrades e manutenção) em vez de pelo serviço gerenciado da nuvem.
