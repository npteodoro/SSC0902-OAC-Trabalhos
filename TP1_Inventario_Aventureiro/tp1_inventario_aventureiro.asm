	.data
	# estrutura de dados para lista encadeada usando alocação dinâmica
	.align 2 #define o alinhamento da memória para o tamanho de 2^2 bytes, 32 bits.
	head: .word 0 # ponteiro para o primeiro nó da lista (NULL = lista vazia)
	
	.align 0 #define o alinhamento da memória para o tamanho de 2^0 bytes, 8 bits.
	welcome: .asciz "Bem-vindo ao Sistema de Inventário!\n"
	menu: .asciz "1 - Adicionar item\n2 - Remover item\n3 - Listar inventário\n4 - Buscar item\n5 - Sair\nOpção: "
	invalid_option: .asciz "Opção inválida! Tente novamente.\n"
	prompt_item: .asciz "Digite o ID do item: "
	msg_add: .asciz "Adicionando item: "
	msg_remove: .asciz "Removendo item: "
	msg_list: .asciz "Listando inventário...\n"
	msg_search: .asciz "Buscando item: "
	msg_exit: .asciz "Saindo...\n"
	newline: .asciz "\n"

	.text
	.globl main #
	.align 2 #define o alinhamento da memória para o tamanho de 2^2 bytes, 32 bits.
main:
	# === IMPRIME BOAS-VINDAS ===
	la a0, welcome # carrega endereço da string de boas-vindas
	jal print_string # chama função para imprimir string

menu_loop:	
	# === EXIBE MENU E LÊ OPÇÃO ===
	la a0, menu # carrega endereço do menu
	jal print_string # chama função para imprimir string

	jal read_int # lê a opção do usuário
	add t0, a0, zero # move a opção para t0
	
	# === VERIFICAÇÃO DAS OPÇÕES ===
	addi t1, zero, 1 # carrega valor 1 em t1
	beq t0, t1, option_add # se opção = 1, vai para adicionar
	addi t1, zero, 2 # carrega valor 2 em t1
	beq t0, t1, option_remove # se opção = 2, vai para remover
	addi t1, zero, 3 # carrega valor 3 em t1
	beq t0, t1, option_list # se opção = 3, vai para listar
	addi t1, zero, 4 # carrega valor 4 em t1
	beq t0, t1, option_search # se opção = 4, vai para buscar
	addi t1, zero, 5 # carrega valor 5 em t1
	beq t0, t1, option_exit # se opção = 5, vai para sair
	
	# === OPÇÃO INVÁLIDA ===
	la a0, invalid_option # carrega endereço da mensagem de erro
	jal print_string # chama função para imprimir string

	j menu_loop # retorna ao loop do menu

# === FUNÇÕES AUXILIARES ===

print_string:
	addi a7, zero, 4 # syscall: imprimir string
	ecall # executa chamada do sistema
	jr ra # retorna para o chamador

print_int:
	addi a7, zero, 1 # syscall: imprimir inteiro
	ecall # executa chamada do sistema
	jr ra # retorna para o chamador

read_int:
	addi a7, zero, 5 # syscall: ler inteiro
	ecall # executa chamada do sistema
	jr ra # retorna para o chamador

# === FUNÇÃO DE ALOCAÇÃO DE MEMÓRIA ===
allocate_node:
	# --- prólogo ---
	# salva o endereço de retorno na pilha por precaução, já que 'ecall' será chamada
	addi sp, sp, -4 # abre espaço na pilha para 1 registrador
	sw ra, 0(sp) # salva o 'ra' na pilha
	
	# --- corpo ---
	# aloca 8 bytes para um novo nó (4 bytes ID + 4 bytes ponteiro)
	addi a0, zero, 8 # número de bytes a alocar
	addi a7, zero, 9 # syscall: sbrk (alocação de memória)
	ecall # executa chamada do sistema
	# retorna em a0 o endereço do bloco alocado
	
	# --- epílogo ---
	# restaura o endereço de retorno antes de sair
	lw ra, 0(sp) # pega o 'ra' original de volta da pilha
	addi sp, sp, 4 # libera o espaço na pilha
	
	jr ra # retorna com segurança

# === FUNÇÃO DE INICIALIZAÇÃO DE NÓ ===
init_node:
	# parâmetros: a0 = endereço do nó, a1 = ID do item
	# inicializa um nó com ID e ponteiro next = NULL
	
	# armazena ID nos primeiros 4 bytes
	sw a1, 0(a0) # guarda ID no offset 0
	
	# inicializa ponteiro next com NULL (0) nos últimos 4 bytes  
	addi t0, zero, 0 # carrega valor NULL (0)
	sw t0, 4(a0) # guarda NULL no offset 4 (ponteiro next)
	
	jr ra # retorna para o chamador

# === OPÇÃO 1: ADICIONAR ITEM ===
option_add:
	# solicita ID do item
	la a0, prompt_item # carrega endereço do prompt
	jal print_string # chama função para imprimir string

	jal read_int # lê o ID do item
	add t1, a0, zero # move o ID para t1
	
	# aloca memória para novo nó
	jal allocate_node # aloca 8 bytes e retorna endereço em a0
	add t2, a0, zero # salva endereço do nó em t2
	
	# inicializa o nó
	add a0, t2, zero # endereço do nó em a0
	add a1, t1, zero # ID do item em a1
	jal init_node # inicializa nó com ID e next = NULL
	
	# TODO: implementar inserção na lista encadeada
	# DECISÃO ARQUITETURAL: permitir IDs duplicados ou não?
	# Opção A: permitir duplicados - apenas inserir no início
	# Opção B: verificar duplicados - percorrer lista antes de inserir
	# - inserir novo nó no início da lista (mais simples)
	# - atualizar ponteiro head para novo nó
	# - fazer novo nó apontar para antigo head
	# [REGIÃO DE IMPLEMENTAÇÃO - INSERIR NA LISTA]
	
	# exibe confirmação
	la a0, msg_add # carrega endereço da mensagem de adição
	jal print_string # chama função para imprimir string

	add a0, t1, zero # move o ID para a0
	jal print_int # chama função para imprimir inteiro

	la a0, newline # carrega endereço da string de nova linha
	jal print_string # chama função para imprimir string
	
	j menu_loop # retorna ao loop do menu

# === OPÇÃO 2: REMOVER ITEM ===
option_remove:
	# solicita ID do item
	la a0, prompt_item # carrega endereço do prompt
	jal print_string # chama função para imprimir string

	jal read_int # lê o ID do item
	add t1, a0, zero # move o ID para t1
	
	# TODO: implementar lógica de remoção da lista encadeada
	# DECISÃO ARQUITETURAL: como tratar IDs duplicados?
	# Opção A: remover apenas primeira ocorrência
	# Opção B: remover todas as ocorrências do ID
	# - percorrer lista para encontrar nó(s) com ID
	# - ajustar ponteiros (nó anterior aponta para próximo)
	# - liberar memória com free (se implementado)
	# - atualizar ponteiro head se removendo primeiro nó
	# - tratar caso de item não encontrado
	# [REGIÃO DE IMPLEMENTAÇÃO - REMOVER]
	
	# exibe confirmação
	la a0, msg_remove # carrega endereço da mensagem de remoção
	jal print_string # chama função para imprimir string
	
	add a0, t1, zero # move o ID para a0
	jal print_int # chama função para imprimir inteiro

	la a0, newline # carrega endereço da string de nova linha
	jal print_string # chama função para imprimir string
	
	j menu_loop # retorna ao loop do menu

# === OPÇÃO 3: LISTAR INVENTÁRIO ===
option_list:
	# TODO: implementar lógica de listagem da lista encadeada
	# DECISÃO ARQUITETURAL: como exibir IDs duplicados?
	# Opção A: mostrar todos (incluindo duplicados)
	# Opção B: mostrar apenas IDs únicos
	# - começar do ponteiro head
	# - percorrer lista seguindo ponteiros next
	# - imprimir ID de cada nó (primeiros 4 bytes)
	# - parar quando ponteiro next = NULL (0)
	# - tratar caso de lista vazia (head = NULL)
	# - considerar numeração ou posição dos itens
	# [REGIÃO DE IMPLEMENTAÇÃO - LISTAR]
	
	la a0, msg_list # carrega endereço da mensagem de listagem
	jal print_string # chama função para imprimir string
	j menu_loop # retorna ao loop do menu

# === OPÇÃO 4: BUSCAR ITEM ===
option_search:
	# solicita ID do item
	la a0, prompt_item # carrega endereço do prompt
	jal print_string # chama função para imprimir string

	jal read_int # lê o ID do item
	add t1, a0, zero # move o ID para t1
	
	# TODO: implementar lógica de busca na lista encadeada
	# DECISÃO ARQUITETURAL: como reportar IDs duplicados?
	# Opção A: parar na primeira ocorrência
	# Opção B: reportar todas as ocorrências e suas posições
	# Opção C: contar quantas vezes o ID aparece
	# - começar do ponteiro head
	# - percorrer lista comparando ID de cada nó
	# - retornar endereço/posição do nó se encontrado
	# - retornar NULL se não encontrado
	# - considerar se deve continuar buscando após encontrar
	# [REGIÃO DE IMPLEMENTAÇÃO - BUSCAR]
	
	# exibe confirmação
	la a0, msg_search # carrega endereço da mensagem de busca
	jal print_string # chama função para imprimir string

	add a0, t1, zero # move o ID para a0
	jal print_int # chama função para imprimir inteiro

	la a0, newline # carrega endereço da string de nova linha
	jal print_string # chama função para imprimir string
	
	j menu_loop # retorna ao loop do menu

# === OPÇÃO 5: SAIR DO PROGRAMA ===
option_exit:
	la a0, msg_exit # carrega endereço da mensagem de saída
	jal print_string # chama função para imprimir string
	addi a7, zero, 10 # syscall: encerrar programa
	ecall # executa chamada do sistema



