# Projeto-AWS/Linux



# Requisitos AWS:
- Gerar uma chave pública para acesso ao ambiente;
- Criar 1 instância EC2 com o sistema operacional Amazon Linux 2 (Família t3.small, 16 GB SSD);
- Gerar 1 Elastic IP e anexar à instância EC2;
- Liberar as portas de comunicação para acesso público: (22/TCP, 111/TCP e UDP, 2049/TCP/UDP, 80/TCP, 443/TCP).
  

# Requisitos Linux: 
- Configurar o NFS entregue;
- Criar um diretório dentro do filesystem do NFS com seu nome;
- Subir um apache no servidor - o apache deve estar online e rodando;
- Criar um script que valide se o serviço está online e envie o resultado da validação para o seu diretório no NFS;
- O script deve conter - Data HORA + nome do serviço + Status + mensagem personalizada de ONLINE ou offline;
- O script deve gerar 2 arquivos de saida: 1 para o serviço online e 1 para o serviço OFFLINE;
- Preparar a execução automatizada do script a cada 5 minutos.

# Execução do Projeto

# Gerando chave pública para acesso ao ambiente:

- Na console AWS, vá até o painel EC2 e no menu no canto esquerdo procure por Rede e Segurança e clique em Pares de Chaves.
- Na tela que será aberta clique em Criar par de chaves.
- Defina um nome para a chave, no meu caso foi "chave-projeto".
- Escolha o tipo de par de chaves que pode ser: RSA ou ED25519.
- Em seguida defina o formato do arquivo: .pem (para acesso OpenSSH) ou .ppk (para acesso via puTTY).
- Crie a chave e salve em local seguro.
- Neste projeto foi criado primeiramente a chave no formato .pem e posteriormente a chave foi convertida em .ppk pelo puTTYgen.

# Criando instância EC2 com sistema operacional Amazon Linux 2 (família t3.small, 16GB SSD):

- Ainda no painel EC2, clique em Instâncias.
- Clique em Executar instância.
- Configure o nome e as tags da instância (Name, CostCenter e Project) para volumes e instâncias.
- Selicione a imagem Amazon Linux 2 AMI (HVM), SSD Volume Type.
- Selecione o tipo de instância t3.small
- Escolha a chave criada anteriomente.
- Escolha o grupo de segurança que permita trafégo de qualquer lugar 0.0.0.0/0.
- Configure o armazenamento para 16 GB gp2 (SSD).
- Execute a instância.
![instancia](https://github.com/Fernandabanjos/Projeto---AWS-Linux/assets/142920603/8acd5cf8-b3c4-4d81-98e4-e32beed0c7de)

	# Gerar um IP elástico e anexar à instância EC2:
- Acesse a AWS na pagina do serviço EC2, e clique em "IPs elásticos" no menu lateral esquerdo.
- Clique em "Alocar endereço IP elástico".
- Selecione o ip alocado e clique em Ações e em Associar endereço IP elástico.
- Selecione a instância EC2 criada anteriormente e clique em Associar.
![ip](https://github.com/Fernandabanjos/Projeto---AWS-Linux/assets/142920603/da9054bb-c0d6-4c29-bf89-222b29ef29c8)

# Configurando gateway de internet:

- Acesse a console AWS e pesquise pelo serviço VPC.
- No menu lateral esquerdo procure por Gateways de Internet e clique em Criar gatway de internet
- Escolha um nome para o gateway.
- Selecione o gateway criado e clique em Ações e Associar à VPC.
- Selecione a mesma VPC da instância criada e associe.

# Configurando rota de internet.

- Ainda no serviço VPC no menu lateral esquerdo procure por Tabela de Rotas.
- Selecione a tabela de rotas da VPC da instância EC2 criada anteriormente.
- Clique em Ações e Editar rotas.
- Adicione rota e é preciso que esteja configurada da seguinte forma:
   Destino: 0.0.0.0/0
   Alvo: Gateway de internet criado anteriormente
- Salve as alterações.


 # Configurando rota sub-rede:

 - Selecione a sub-rede que está associada a instância criada.
 - Clique em ações e editar rotas.
 - Clique em adicionar rota  e é preciso que esteja configurada da seguinte forma:
   Destino: 0.0.0.0/0
   Alvo: Gateway de internet e, selecione o gateway que criado anteriormente.

# Liberar as portas de comunicação para acesso público.
- Acesse a console AWS na pagina do serviço EC2, e clicque em Segurança e depois em Grupos de segurança no menu lateral esquerdo.
- Selecione o grupo de segurança da instância EC2 criada anteriormente.
- Clique em Editar regras de entrada.
- Configurar as seguintes regras:
![portas](https://github.com/Fernandabanjos/Projeto---AWS-Linux/assets/142920603/24170a53-5f46-470a-ade3-051dd78b3e18)

	# Servidor NFS a partir do Elastic File System (EFS) - Security Group

- Acesse painel EC2 e clique em Security groups e crie um novo grupo de segurança.
- Defina um nome e associe a mesma VPC que a instância se encontra.
- Em Regras de entrada adicione esta regra:
  ![efs](https://github.com/Fernandabanjos/Projeto---AWS-Linux/assets/142920603/48c71189-1f47-4c62-9776-ba31014f3936)

- No campo de origem escolha o mesmo grupo de segurança que foi criado para a instância EC2.
  

  # Serviço de Elastica File System (EFS):

	- No console AWS, pesquise pelo serviço de EFS;
  - No menu lateral esquerdo, clique em Sistemas de arquivos e, na sequência, em Criar sistema de arquivos.
  - Adicione um nome para o sistema de arquivos e escolha a opção Personalizar.
  - Selecione a opção One zone e, também, a mesma zona de disponibilidade em que a instância foi criada.
  - Mantenha as opções pré-definidas, altere apenas o grupo de segurança para o grupo que for para o serviço EFS;
  - Abra o sistema de arquivos criado e clique em Anexar, salve o comando `sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 [DNS do EFS]:/ [caminho local]` pois será necessário mais a frente.


	# Configurando o NFS:

 - Abra o terminal da instância EC2 criada e execute o comando `sudo su`.
 - Execute o comando `sudo yum update -y` para garantir que serão sempre as versões mais atualizadas dos arquivos Linux que rodarão.
 - Installe o pacote para NFS com comando `sudo yum install -y amazon-efs-utils`.
 - Crie um novo diretório para o NFS usando o comando sudo mkdir /mnt/efs.
Montar o NFS no diretório criado usando o comando `sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 [DNS do EFS]:/ [caminho local]`.
 - Para verficar se o NFS foi montado use o comando `df -h`.
 - Foi criado, também, um diretório com o usuário fernanda com o comando `sudo mkdir /mnt/efs/fernanda`.
![Conectando](https://github.com/Fernandabanjos/Projeto---AWS-Linux/assets/142920603/e66e24d4-8d0c-4fb7-b930-131e7661dcf5)


# Configurando o Apache:

- Execute o comando sudo yum update -y para atualizar o sistema.
- Execute o comando sudo yum install httpd -y para instalar o apache.
- Execute o comando sudo systemctl start httpd para iniciar o apache.
- Execute o comando sudo systemctl enable httpd para habilitar o apache para iniciar automaticamente.
- Execute o comando sudo systemctl status httpd para verificar o status do apache.
- Para parar o apache, execute o comando sudo systemctl stop httpd.
![apache](https://github.com/Fernandabanjos/Projeto---AWS-Linux/assets/142920603/84a722cd-b779-4063-a5d4-7e727bf02cf6)

	# Configurando o scrip de validação:

	- Acesso o diretório `/var/www/html`.
  - Execute o comando `sudo nano index.html` o que for digitado no arquivo irá aparecer na página do acessada pelo IP publico. Salve o arquivo e abra a página no navegador para verificar se funcionou.
 - O scrip usado foi:
![html](https://github.com/Fernandabanjos/Projeto---AWS-Linux/assets/142920603/e2b42d0c-6fd9-48f4-ad28-00a41d82bc49)

![apache1](https://github.com/Fernandabanjos/Projeto---AWS-Linux/assets/142920603/9296f3f5-fb36-4d03-b6ce-838f2621404b)


# Criando o scrip dos arquivos online ou offline e execução automatizada do script a cada 5 minutos:

- Execute o comando `nano service_status.sh` dentro do diretório /mnt/efs/fernanda e crie o script.
- Salve o arquivo e execute o comando `sudo chmod +x service_status.sh`.
- Execute o comando `./service_status.sh`.
- Execute o comando `EDITOR=nano crontab -e` e digite `*/5 * * * * /[caminho de onde está o script/nome do script]`.
- Salve o arquio.
- Para verificar se funcionou é preciso esperar alguns minutos para que os arquivos .txt atualizem. O documento pode ser lido com o comando `cat httpd-online.sh`.
- Para a validação do serviço offline é necessário interromper o apache com o comando `sudo systemctl stop httpd` e novamente aguardar alguns minutos para o arquivo httpd-offline.txt seja atualizado.
  
![script](https://github.com/Fernandabanjos/Projeto---AWS-Linux/assets/142920603/ec68b1cc-fbd4-4bf5-8af3-bf552cc2f44b)

	

	


 

  
	
