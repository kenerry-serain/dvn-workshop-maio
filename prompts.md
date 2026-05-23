## criar as subredes

Refatore a stack de redes considerando o seguinte. Devemos ter 4 subnets, duaspublicas e duas privadas. As publicas terão o seguinte CIDR: 10.0.0.0/26 e  
10.0.0.64/26. As privadas 10.0.0.128/26 e 10.0.0.192/26. A VPC 10.0.0.0/24.Devemos ter um unico NAT Gateway para as subnets privadas.

## criar skill

/skill-creator Crie uma skill terraform-deploy, para fazer o deploy de multiplas stacks. Quando parametrizado 01-networking-stack-ai, faça o deploy  
 somente desta stack, quando não parametrizado, faça o deploy de todas stacks. Antes do deploy, rode o terraform fmt, depois o validate, depois o plan e  
 printe o plan e depois o apply com auto-approve. Sempre ignore a stack de remote backend caso exista.
