# 🧠 eLORETA: Aprimoramento da Resolução Espacial do EEG

**Desenvolvido por Yuri Pio Macedo** durante pesquisa no Laboratório de Engenharia Biomédica (BioLab) da Universidade Federal de Uberlândia (UFU).

Este repositório contém uma arquitetura computacional desenvolvida em MATLAB para a resolução do Problema Inverso em Eletroencefalografia (EEG), utilizando a Tomografia Eletromagnética Cerebral de Baixa Resolução Exata (*exact Low Resolution Electromagnetic Tomography* — eLORETA).

O *pipeline* foi projetado e validado para o rastreamento tridimensional de fontes neurais sob estimulação somatossensorial eletrotátil, com foco na extração do potencial evocado P300. A proposta busca reduzir o borramento espacial das estimativas e contribuir para o aprimoramento da localização de fontes neurais em aplicações de Interfaces Cérebro-Máquina (ICMs).

---

## 📚 Publicação e resultados

A fundamentação teórica, a aplicação metodológica do código e os resultados numéricos obtidos por este algoritmo estão documentados no Trabalho de Conclusão de Curso (TCC), defendido em **5 de agosto de 2026**.

📄 **Acesse o documento oficial no Repositório Institucional da UFU:**

[https://repositorio.ufu.br/handle/123456789/49522](https://repositorio.ufu.br/handle/123456789/49522)

---

## ✨ Funcionalidades

- **Pré-processamento e integração:** conversão de matrizes de superfície epocadas do EEGLAB para o espaço de fontes do FieldTrip.
- **Modelagem do problema direto (simulação):** injeção artificial de dipolos sintéticos em coordenadas corticais conhecidas, com adição parametrizada de ruído branco para testes computacionais.
- **Resolução do problema inverso:** aplicação da técnica eLORETA sobre uma malha volumétrica padronizada no espaço MNI, com resolução de 5 mm e 12.213 *voxels*.
- **Renderização 3D:** supressão não linear de ruídos e projeção volumétrica das fontes estimadas sobre uma representação da superfície cortical.

---

## 🛠️ Pré-requisitos

Para executar as rotinas, é necessário configurar o seguinte ambiente:

- **MATLAB** — desenvolvido e testado na versão R2026a.
- **EEGLAB** — com o *plugin* `DIPFIT` atualizado.
- **FieldTrip** — adicionado ao `path` do MATLAB para disponibilizar as rotinas de estimativa de fontes e os *templates* MNI.

> **Observação:** os resultados podem variar conforme as versões das ferramentas, os dados de entrada e a configuração do ambiente.

---

## 🚀 Como utilizar

### 1. Clone o repositório

```bash
git clone https://github.com/yuripio/eLOERTA.git
```

### 2. Configure o MATLAB

Abra o MATLAB e adicione a pasta do projeto ao `path`.

### 3. Execute o script principal

Execute o script principal localizado na pasta ou arquivo `Main` do projeto. A interface solicitará a seleção dos arquivos `.mat` que contêm os dados epocados/segmentados.

### 4. Selecione a latência de interesse

O sistema exibirá as curvas temporais (*Event-Related Potentials* — ERPs) dos canais centrais. Analise o gráfico e informe a latência-alvo em segundos na janela de diálogo. Por exemplo, para 297 ms, insira:

```text
0.297
```

### 5. Visualize o resultado

Após o cálculo da solução inversa, o resultado volumétrico será apresentado na renderização 3D do córtex.

---

## 📄 Licença

Este projeto está licenciado sob a **MIT License**. Você pode utilizar, modificar e distribuir o código para fins acadêmicos ou comerciais, desde que mantenha os créditos de autoria e cumpra as condições da licença. Consulte o arquivo [`LICENSE`](LICENSE) para obter mais detalhes.

---

## 📬 Contato

**Yuri Pio Macedo**

📧 E-mail: [ypiomacedo@gmail.com](mailto:ypiomacedo@gmail.com)
