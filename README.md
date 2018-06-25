# data-worker

Esse repositório possui scripts que são utilizados para rodar os scripts que
capturam dados do Brasil.IO, mas você pode utilizá-lo para rodar qualquer
crawler que desejar. Siga os seguintes passos:

- Crie um script que baixa/converte/limpa os dados que deseja (seu script
  deverá utilizar o diretório `data` para salvar os dados - tanto os de
  download quanto os de saída, sugestão: `data/download` e `data/output`);
- Crie um script chamado `run.sh` com o comando principal que seu script irá
  executar;
- Crie um repositório Git de código público com seu script;
- Clone esse repositório;
- Rode o comando `worker.sh all` passando os parâmetros relativos a seu script,
  como no exemplo:

```bash
git_url="https://github.com/turicas/socios-brasil.git"
image="turicas/socios-brasil:1.0.0"
code_path="/tmp/code-socios-brasil"
data_path="/tmp/data-socios-brasil"

./worker.sh all $git_url $image $code_path $data_path
```

Você precisará do Docker e a primeira vez que executará o comando ele demorará
um pouco para baixar as imagens base. O código será rodado utilizando o
[herokuish](https://github.com/gliderlabs/herokuish), que é um software livre
que simula o processo de criação de imagens do [Heroku](https://heroku.com/) -
por padrão, somente a linguagem Python é suportada (caso queira utilizar outra,
altere o `runtime.txt`).

O comando `worker.sh all` executará os seguintes passos:

- Clonar o repositório em `$git_url` e colocá-lo em `$code_path` (diretório na
  máquina host, não no container);
- Copiar os arquivos `Dockerfile`, `.dockerignore` e `runtime.txt` desse
  repositório para `$git_url`;
- Executar a criação da imagem do container (de nome `$image`) a partir de
  `$code_path`;
- Executar o script `run.sh` dentro da imagem;

Ao final do processo você poderá acessar `$data_path` na máquina host para
acessar os arquivos gerados pelo script.
