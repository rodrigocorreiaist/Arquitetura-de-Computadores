#
# IAC 2023/2024 k-means
# 
# Grupo: 39
# Campus: Alameda
#
# Autores:
# 1110688, Rodrigo Correia
# 1109248 , Pedro Luis
# 1109389, Hugo Oliveira
#
# Tecnico/ULisboa


# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...


# Variaveis em memoria
.data
#Input A - linha inclinada
n_points:    .word 9
points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8
clusters:    .zero 36

#Input B - Cruz
#n_points:    .word 5
#points:      .word 4,2, 5,1, 5,2, 5,3 6,2
#clusters:    .zero 20

#Input C
#n_points:    .word 23
#points:      .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8
#clusters:    .zero 92

#Input D
#n_points:    .word 30
#points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10
#clusters:    .zero 120

# Valores de centroids e k a usar na 1a parte do projeto:
#centroids:   .word 0,0
#k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .word 0,0, 10,0, 0,10
k:           .word 3
L:           .word 10
centroidsAnteriores: .zero 12
presence:    .zero 12

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
#clusters:    
         


#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0 
.equ         white      0xffffff



# Codigo
 
.text
    # Chama funcao principal da 1a parte do projeto
    #jal mainSingleCluster

    # Descomentar na 2a parte do projeto:
    jal mainKMeans
    
    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    li a3, 0x20           # Carrega o valor 32 (0x20 em hexadecimal) no registo a3
    sub a1, a3, a1        # Subtrai o valor no registo a1 do valor no registo a3 e armazena o resultado em a1
    addi a1, a1, -1       # Subtrai 1 do valor no registo a1 e armazena o resultado em a1
    li a3, 0x20           # Carrega o valor 32 (0x20 em hexadecimal) no registo a3 novamente
    mul a3, a3, a1        # Multiplica os valores nos registos a3 e a1 e armazena o resultado em a3
    add a3, a3, a0        # Adiciona os valores nos registos a3 e a0 e armazena o resultado em a3
    slli a3, a3, 2        # Desloca os bits do valor no registo a3 2 posições para a esquerda (multiplica por 4) e armazena o resultado em a3
    li a0, 0xf0000000     # Carrega o valor 0xf0000000 no registo a0
    add a3, a3, a0        # Adiciona os valores nos registos a3 e a0 e armazena o resultado em a3. Agora a3 contém o endereço de memória onde o ponto será impresso
    sw a2, 0(a3)          # Armazena o valor no registo a2 no endereço de memória especificado por a3
    jr ra                 # Retorna para o endereço de retorno armazenado no registo ra
    

### cleanScreen
# Limpa todos os pontos do ecr?
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    # POR IMPLEMENTAR (1a parte)
    addi sp sp -4          # Decrementa o ponteiro da pilha em 4 para criar espaço para o endereço de retorno
    sw ra 0(sp)            # Salva o endereço de retorno na pilha

    li t1 LED_MATRIX_0_BASE # Carrega o endereço base da matriz de LED no registo t1
    li t0 32                # Carrega o valor 32 no registo t0, que representa o tamanho do lado da matriz
    mul t0 t0 t0            # Calcula o quadrado do tamanho do lado para obter o tamanho total da matriz
    slli t0 t0 2            # Multiplica o tamanho total por 4 para obter o número total de bytes necessários para a matriz

    add t0 t0 t1            # Adiciona o endereço base ao tamanho total para obter o endereço final da matriz
    li t2 white             # Carrega a cor branca no registo t2

    # loop_clean_screen
    # Percorre a matriz e pinta de branco

    loop_clean_screen:
        bgt t1 t0 fimLoopCleanScreen  # Se o endereço atual for maior que o endereço final, termina o loop
        # atribui a cor branca aos pontos 
        sw t2, 0(t1)                  # Pinta o pixel atual de branco
        sw t2, 4(t1)                  # Pinta o próximo pixel de branco
        sw t2, 8(t1)                  # Pinta o pixel após o próximo de branco
        sw t2, 12(t1)                 # Continua pintando os pixels de branco
        sw t2, 16(t1)
        sw t2, 20(t1)
        sw t2, 24(t1)
        sw t2, 28(t1)
        addi t1 t1 32                 # Avança para o próximo conjunto de pixels
        j  loop_clean_screen          # Volta para o início do loop

    fimLoopCleanScreen:
        lw ra 0(sp)                   # Recupera o endereço de retorno da pilha
        addi sp sp 4                  # Incrementa o ponteiro da pilha em 4 para limpar o espaço que foi criado anteriormente
        jr ra                         # Retorna para o endereço de retorno

# printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    addi sp, sp, -44       # Decrementa o ponteiro da pilha em 44 para criar espaço para os registos
    sw s0, 0(sp)           # Salva o valor do registo s0 na pilha
    sw ra, 4(sp)           # Salva o valor do registo ra (endereço de retorno) na pilha
    sw t0, 8(sp)           # Salva o valor do registo t0 na pilha
    sw t1, 12(sp)          # Salva o valor do registo t1 na pilha
    sw t2, 16(sp)          # Salva o valor do registo t2 na pilha
    sw t3, 20(sp)          # Salva o valor do registo t3 na pilha
    sw t4, 24(sp)          # Salva o valor do registo t4 na pilha
    sw t5, 28(sp)          # Salva o valor do registo t5 na pilha
    sw a0, 32(sp)          # Salva o valor do registo a0 na pilha
    sw a1, 36(sp)          # Salva o valor do registo a1 na pilha
    sw a2, 40(sp)          # Salva o valor do registo a2 na pilha

    la t0, points          # Carrega o endereço dos pontos no registo t0
    lw t1, n_points        # Carrega o número de pontos no registo t1
    la t2, colors          # Carrega o endereço das cores no registo t2
    lw t3, k               # Carrega o valor de k no registo t3

    li s0, 0               # Inicializa o índice do loop em 0

    # Loop para k = 1
    li t4, 1               # Carrega o valor 1 no registo t4
    beq t3, t4, loop_k1    # Se k == 1, pula para loop_k1

loop_kg1:
    bge s0, t1, fim_do_loop  # Se o índice (s0) >= número de pontos (t1), termina o loop
    slli t4, s0, 3           # Multiplica o índice do ponto por 8 (cada ponto ocupa 2 words)
    add t4, t0, t4           # Calcula o endereço do ponto atual
    lw a0, 0(t4)             # Carrega o x do ponto
    lw a1, 4(t4)             # Carrega o y do ponto
    jal nearestCluster       # Chama nearestCluster para obter o índice do cluster
    slli a0, a0, 2           # Multiplica o índice do cluster por 4 (tamanho de word)
    add t5, t2, a0           # Calcula o endereço da cor correspondente
    lw a0, 0(t4)             # Carrega o x do ponto
    lw a2, 0(t5)             # Carrega a cor do cluster
    jal printPoint           # Chama a função printPoint para pintar o ponto (x, y, cor)
    addi s0, s0, 1           # Incrementa o índice do loop
    li t4, 1                 # Carrega o valor 1 no registo t4
    j loop_kg1               # Repete o loop

loop_k1:
    bge s0, t1, fim_do_loop  # Se o índice (s0) >= número de pontos (t1), termina o loop
    slli t4, s0, 3           # Multiplica o índice do ponto por 8 (cada ponto ocupa 2 words)
    add t4, t0, t4           # Calcula o endereço do ponto atual
    lw a0, 0(t4)             # Carrega o x do ponto
    lw a1, 4(t4)             # Carrega o y do ponto
    lw a2, 0(t2)             # Carrega a cor vermelha (primeira cor no vetor colors)
    jal printPoint           # Chama a função printPoint para pintar o ponto (x, y, cor)
    addi s0, s0, 1           # Incrementa o índice do loop
    j loop_k1                # Repete o loop

fim_do_loop:
    lw s0, 0(sp)           # Restaura o valor do registo s0 da pilha
    lw ra, 4(sp)           # Restaura o valor do registo ra (endereço de retorno) da pilha
    lw t0, 8(sp)           # Restaura o valor do registo t0 da pilha
    lw t1, 12(sp)          # Restaura o valor do registo t1 da pilha
    lw t2, 16(sp)          # Restaura o valor do registo t2 da pilha
    lw t3, 20(sp)          # Restaura o valor do registo t3 da pilha
    lw t4, 24(sp)          # Restaura o valor do registo t4 da pilha
    lw t5, 28(sp)          # Restaura o valor do registo t5 da pilha
    lw a0, 32(sp)          # Restaura o valor do registo a0 da pilha
    lw a1, 36(sp)          # Restaura o valor do registo a1 da pilha
    lw a2, 40(sp)          # Restaura o valor do registo a2 da pilha
    addi sp, sp, 44        # Incrementa o ponteiro da pilha em 44 para limpar o espaço que foi criado anteriormente
    jr ra                  # Retorna para o endereço de retorno                 


### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    addi sp, sp, -28       # Ajusta o ponteiro da pilha para criar espaço para os registos
    sw ra, 0(sp)           # Salva o valor do registo ra (endereço de retorno) na pilha
    sw t0, 4(sp)           # Salva o valor do registo t0 na pilha
    sw t1, 8(sp)           # Salva o valor do registo t1 na pilha
    sw t2, 12(sp)          # Salva o valor do registo t2 na pilha
    sw a0, 16(sp)          # Salva o valor do registo a0 na pilha
    sw a1, 20(sp)          # Salva o valor do registo a1 na pilha
    sw a2, 24(sp)          # Salva o valor do registo a2 na pilha

    la t0, centroids       # Carrega o endereço dos centroides no registo t0
    lw t1, k               # Carrega o valor de k (número de centroides) no registo t1
    
    li t2, 0               # Inicializa o índice do centróide no registo t2

printCentroids_loop:
    bge t2, t1, end_printCentroids  # Se o índice do centróide (t2) >= número de centroides (t1), termina o loop

    lw a0, 0(t0)           # Carrega a coordenada x do centróide no registo a0
    lw a1, 4(t0)           # Carrega a coordenada y do centróide no registo a1
    li a2, black           # Carrega a cor preta no registo a2
    jal printPoint         # Chama a função printPoint para pintar o centróide de preto

    addi t0, t0, 8         # Avança para o próximo par de coordenadas
    addi t2, t2, 1         # Incrementa o índice do centróide

    j printCentroids_loop  # Repete o loop

end_printCentroids:
    lw ra, 0(sp)           # Restaura o valor do registo ra (endereço de retorno) da pilha
    lw t0, 4(sp)           # Restaura o valor do registo t0 da pilha
    lw t1, 8(sp)           # Restaura o valor do registo t1 da pilha
    lw t2, 12(sp)          # Restaura o valor do registo t2 da pilha
    lw a0, 16(sp)          # Restaura o valor do registo a0 da pilha
    lw a1, 20(sp)          # Restaura o valor do registo a1 da pilha
    lw a2, 24(sp)          # Restaura o valor do registo a2 da pilha
    addi sp, sp, 28        # Ajusta o ponteiro da pilha de volta
    jr ra                  # Retorna para o endereço de retorno


### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    # Reserva espaço na pilha e salva os registos
    addi sp sp -60         # Decrementa o ponteiro da pilha para alocar 60 bytes
    sw ra 0(sp)            # Salva o valor de retorno
    sw a2 4(sp)            # Salva o registo a2
    sw a3 8(sp)            # Salva o registo a3
    sw a4 12(sp)           # Salva o registo a4
    sw a5 16(sp)           # Salva o registo a5
    sw a6 20(sp)           # Salva o registo a6
    sw a0 24(sp)           # Salva o registo a0
    sw a1 28(sp)           # Salva o registo a1
    sw t0 32(sp)           # Salva o registo t0
    sw t1 36(sp)           # Salva o registo t1
    sw t2 40(sp)           # Salva o registo t2
    sw t3 44(sp)           # Salva o registo t3
    sw t4 48(sp)           # Salva o registo t4
    sw t5 52(sp)           # Salva o registo t5
    sw t6 56(sp)           # Salva o registo t6

    # Carrega o valor de k em t1 e compara com 1
    lw t1 k                # Carrega o valor de k no registo t1
    li t2 1                # Carrega o valor 1 no registo t2
    beq t1 t2 CalculateByPoints  # Se t1 == 1, pula para CalculateByPoints
    bgt t1 t2 CalculateByClusters # Se t1 > 1, pula para CalculateByClusters

CalculateByPoints:
    # Calcula os centroides usando os pontos
    lw t0 n_points         # Carrega o número de pontos em t0
    slli t0 t0 3           # Multiplica t0 por 8 (número de bytes por ponto xy)
    li t1 0                # Inicializa o índice i em t1
    li t3 0                # Inicializa a soma de x em t3
    li t4 0                # Inicializa a soma de y em t4

    # Loop para percorrer os pontos e calcular a média
    LoopPointsCentroids:
        bge t1 t0 EndLoopPointsCentroids  # Se t1 >= t0, termina o loop
        la t2 points        # Carrega o endereço base de points em t2
        add t2 t2 t1        # Adiciona t1 ao endereço base de points

        lw t5 0(t2)         # Carrega x do ponto atual em t5
        lw t6 4(t2)         # Carrega y do ponto atual em t6

        add t3 t3 t5        # Soma x a t3
        add t4 t4 t6        # Soma y a t4

        addi t1 t1 8        # Incrementa t1 em 8 para o próximo ponto
        j LoopPointsCentroids # Salta para o início do loop

    # Fim do loop
    EndLoopPointsCentroids:
        lw t0 n_points      # Carrega o número de pontos em t0
        div t3 t3 t0        # Calcula a média de x
        div t4 t4 t0        # Calcula a média de y

        la t0 centroids     # Carrega o endereço base de centroids em t0
        sw t3 0(t0)         # Salva a média x em centroids
        sw t4 4(t0)         # Salva a média y em centroids

        # Restaura os registos e retorna
        lw ra 0(sp)         # Restaura o valor de retorno
        addi sp sp 4        # Incrementa o ponteiro da pilha
        jr ra               # Retorna da função

CalculateByClusters:
    # Calcula os centroides usando os clusters
    lw t0 n_points         # Carrega o número de pontos em t0
    lw t1 k                # Carrega o valor de k em t1
    la t2 points           # Carrega o endereço base de points em t2
    la t3 clusters         # Carrega o endereço base de clusters em t3
    li t4 0                # Inicializa o iterador dos clusters em t4
    li t5 0                # Inicializa auxiliar t5
    li t6 0                # Inicializa o número do cluster a ser percorrido em t6
    li a2 0                # Inicializa o número de pontos de cada cluster em a2
    li a3 0                # Inicializa a soma de x em a3
    li a4 0                # Inicializa a soma de y em a4

    # Loop para percorrer os clusters
    LoopClusters:
        bge t6 t1 EndLoopClusters # Se t6 >= t1, termina o loop
        IterationClusters:
            bge t4 t0 EndIterationClusters # Se t4 >= t0, termina a iteração
            la t3 clusters        # Carrega o endereço base de clusters em t3
            slli t5 t4 2          # Multiplica t4 por 4 (offset do cluster)
            add t3 t3 t5          # Adiciona o offset ao endereço base de clusters
            lw t5 0(t3)           # Carrega o valor do cluster atual em t5
            bne t5 t6 NextPoint   # Se t5 != t6, pula para NextPoint

            # Encontra o ponto correspondente em points
            slli t5 t4 3          # Multiplica t4 por 8 (offset do ponto)
            add t5 t2 t5          # Adiciona o offset ao endereço base de points

            lw a0 0(t5)           # Carrega x do ponto atual em a0
            lw a1 4(t5)           # Carrega y do ponto atual em a1

            add a3 a3 a0          # Soma x a a3
            add a4 a4 a1          # Soma y a a4

            addi a2 a2 1          # Incrementa o número de pontos em a2

        NextPoint:
            addi t4 t4 1          # Incrementa t4 para o próximo ponto
            j IterationClusters   # Salta para o início da iteração

    EndIterationClusters:
        beq a2 x0 ClusterWithoutPoint # Se a2 == 0, pula para ClusterWithoutPoint

        div a3 a3 a2            # Calcula a média de x
        div a4 a4 a2            # Calcula a média de y

        slli a5 t6 3            # Multiplica t6 por 8 (offset do centroid)
        la a6 centroids         # Carrega o endereço base de centroids em a6
        add a6 a6 a5            # Adiciona o offset ao endereço base de centroids

        sw a3 0(a6)             # Salva a média x em centroids
        sw a4 4(a6)             # Salva a média y em centroids

    ClusterWithoutPoint:
        addi t6 t6 1            # Incrementa t6 para o próximo cluster
        li t4 0                # Reinicializa o iterador dos clusters 
        li a2 0                # Reinicializa o número de pontos de cada cluster 
        li a3 0                # Reinicializa a soma de x
        li a4 0                # Reinicializa a soma de y

        j LoopClusters          # Salta para o início do loop de clusters

    EndLoopClusters:
        # Restaura os registos e retorna
        lw ra 0(sp)             # Restaura o valor de retorno
        lw a2 4(sp)             # Restaura o registo a2
        lw a3 8(sp)             # Restaura o registo a3
        lw a4 12(sp)            # Restaura o registo a4
        lw a5 16(sp)            # Restaura o registo a5
        lw a6 20(sp)            # Restaura o registo a6
        lw a0 24(sp)            # Restaura o registo a0
        lw a1 28(sp)            # Restaura o registo a1
        lw t0 32(sp)            # Restaura o registo t0
        lw t1 36(sp)            # Restaura o registo t1
        lw t2 40(sp)            # Restaura o registo t2
        lw t3 44(sp)            # Restaura o registo t3
        lw t4 48(sp)            # Restaura o registo t4
        lw t5 52(sp)            # Restaura o registo t5
        lw t6 56(sp)            # Restaura o registo t6
        addi sp sp 60           # Incrementa o ponteiro da pilha para desalocar os 60 bytes
        jr ra                   # Retorna da função

### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:
    addi sp, sp, -4
    sw ra, 0(sp)
    #1. Coloca k=1 (caso nao esteja a 1)
     li s2, 1

    #2. cleanScreen
    jal cleanScreen

    #3. printClusters
    jal printClusters

    #4. calculateCentroids
    # POR IMPLEMENTAR (1a parte)
    jal calculateCentroids
    #5. printCentroids
    # POR IMPLEMENTAR (1a parte)
    jal printCentroids
    #6. Termina
    lw ra, 0(sp)
    addi sp, sp, 4

    jr ra

random_number:
    addi sp, sp, -16      # Ajusta o stack pointer para alocar espaço para 4 registos
    sw ra, 0(sp)          # Salva o valor de ra na pilha
    sw a7, 4(sp)          # Salva o valor de a7 na pilha
    sw t0, 8(sp)          # Salva o valor de t0 na pilha
    sw t1, 12(sp)         # Salva o valor de t1 na pilha
    # Chamada de sistema para obter o tempo (Time_msec)
    li a7, 30             # Carrega o número da syscall para Time_msec em a7
    ecall                 # Executa a chamada de sistema

    # Carregar os milissegundos baixos em uma semente
    mv t0, a0             # Move os 32 bits baixos de a0 (milissegundos desde a epoch) para t0

    # Calcular o número aleatório (0 a 31)
    li t1, 32             # Carrega o valor 32 em t1
    rem a0, t0, t1        # Calcula o número aleatório t0 % 32 e armazena em a0
    bgt a0, x0, fim       # Se a0 for positivo, salta para fim
    neg a0, a0            # Caso contrário, inverte o sinal de a0
    fim:
    lw ra, 0(sp)          # Restaura o valor de ra da pilha
    lw a7, 4(sp)          # Restaura o valor de a7 da pilha
    lw t0, 8(sp)          # Restaura o valor de t0 da pilha
    lw t1, 12(sp)         # Restaura o valor de t1 da pilha
    addi sp, sp, 16       # Ajusta o stack pointer para desalocar espaço dos registos
    jr ra                 # Retorna da função

# Função para inicializar os centroides
initializeCentroids:
    addi sp, sp, -20       # Ajusta o stack pointer para alocar espaço para 5 registos
    sw ra, 0(sp)           # Salva o valor de ra na pilha
    sw t0, 4(sp)           # Salva o valor de t0 na pilha
    sw t1, 8(sp)           # Salva o valor de t1 na pilha
    sw t2, 12(sp)          # Salva o valor de t2 na pilha
    sw a0, 16(sp)          # Salva o valor de a0 na pilha

    la t2, centroids       # Carrega o endereço dos centroides em t2
    lw t1, k               # Carrega o valor de k (número de centroides) em t1

    li t0, 0               # Inicializa o índice do centroide em t0

initialize_loop:
    bge t0, t1, end_initializeCentroids  # Se t0 >= k, termina o loop

    # Gera uma coordenada x pseudoaleatória
    jal random_number      # Chama a função random_number
    sw a0, 0(t2)           # Salva o valor x no vetor de centroides

    # Gera uma coordenada y pseudoaleatória
    jal random_number      # Chama a função random_number
    sw a0, 4(t2)           # Salva o valor y no vetor de centroides

    addi t2, t2, 8         # Avança para o próximo par de coordenadas
    addi t0, t0, 1         # Incrementa o índice do centroide

    j initialize_loop      # Repete o loop

end_initializeCentroids:
    lw ra, 0(sp)           # Restaura o valor de ra da pilha
    lw t0, 4(sp)           # Restaura o valor de t0 da pilha
    lw t1, 8(sp)           # Restaura o valor de t1 da pilha
    lw t2, 12(sp)          # Restaura o valor de t2 da pilha
    lw a0, 16(sp)          # Restaura o valor de a0 da pilha
    addi sp, sp, 20        # Ajusta o stack pointer para desalocar espaço dos registos
    jr ra                  # Retorna da função

# Calcula a distância de Manhattan entre (x0,y0) e (x1,y1)
manhattanDistance:
    addi sp, sp, -24       # Ajusta o stack pointer para alocar espaço para 6 registos
    sw a1, 0(sp)           # Salva o valor de a1 na pilha
    sw a2, 4(sp)           # Salva o valor de a2 na pilha
    sw a3, 8(sp)           # Salva o valor de a3 na pilha
    sw ra, 12(sp)          # Salva o valor de ra na pilha
    sw t0, 16(sp)          # Salva o valor de t0 na pilha
    sw t1, 20(sp)          # Salva o valor de t1 na pilha
    
    sub t0, a0, a2         # Calcula t0 = x0 - x1
    sub t1, a1, a3         # Calcula t1 = y0 - y1

    bgez t0, x_abs         # Se t0 >= 0, salta para x_abs
    neg t0, t0             # Caso contrário, t0 = -t0
    x_abs:

    bgez t1, y_abs         # Se t1 >= 0, salta para y_abs
    neg t1, t1             # Caso contrário, t1 = -t1
    y_abs:

    add a0, t0, t1         # Calcula a0 = |x0 - x1| + |y0 - y1|
    lw a1, 0(sp)           # Restaura o valor de a1 da pilha
    lw a2, 4(sp)           # Restaura o valor de a2 da pilha
    lw a3, 8(sp)           # Restaura o valor de a3 da pilha
    lw ra, 12(sp)          # Restaura o valor de ra da pilha
    lw t0, 16(sp)          # Restaura o valor de t0 da pilha
    lw t1, 20(sp)          # Restaura o valor de t1 da pilha
    addi sp, sp, 24        # Ajusta o stack pointer para desalocar espaço dos registos
    jr ra                  # Retorna da função

nearestCluster:
    addi sp, sp, -40       # Ajusta o stack pointer para alocar espaço para 10 registos
    sw a0, 0(sp)           # Salva a0 (x do ponto) na pilha
    sw a1, 4(sp)           # Salva a1 (y do ponto) na pilha
    sw ra, 8(sp)           # Salva o valor de ra na pilha
    sw t0, 12(sp)          # Salva t0 na pilha
    sw t1, 16(sp)          # Salva t1 na pilha
    sw t2, 20(sp)          # Salva t2 na pilha
    sw t3, 24(sp)          # Salva t3 na pilha
    sw t4, 28(sp)          # Salva t4 na pilha
    sw a3, 32(sp)          # Salva a3 na pilha
    sw t5, 36(sp)          # Salva t5 na pilha
    la t0, centroids       # Carrega o endereço dos centroides em t0
    li t1, 0               # Inicializa o índice do cluster mais próximo em t1
    li t2, 0x7FFFFFFF      # Inicializa a menor distância com um valor grande
    li t4, 0               # Inicializa o contador de clusters em t4
    lw t3, k               # Carrega o valor de k (número de clusters) em t3
    
loop_clusters:
    bge t4, t3, fim_clusters  # Se t4 >= k, termina o loop
    lw t5, 0(t0)           # Carrega x do centroid em t5
    lw t6, 4(t0)           # Carrega y do centroid em t6
    lw a0, 0(sp)           # Restaura a0 (x do ponto) da pilha
    lw a1, 4(sp)           # Restaura a1 (y do ponto) da pilha
    mv a2, t5              # Define a2 como x do centroid
    mv a3, t6              # Define a3 como y do centroid
    jal manhattanDistance  # Calcula a distância de Manhattan
    blt a0, t2, atualiza_cluster  # Se a distância calculada for menor, atualiza o cluster mais próximo
    j proximo_cluster      # Salta para a próxima iteração

atualiza_cluster:
    mv t2, a0              # Atualiza a menor distância
    mv t1, t4              # Atualiza o índice do cluster mais próximo

proximo_cluster:
    addi t0, t0, 8         # Avança para o próximo centroid
    addi t4, t4, 1         # Incrementa o contador de clusters
    j loop_clusters        # Repete o loop
    
fim_clusters:
    mv a0, t1              # Retorna o índice do cluster mais próximo em a0
    lw ra, 8(sp)           # Restaura o valor de ra da pilha
    lw t0, 12(sp)          # Restaura t0 da pilha
    lw t1, 16(sp)          # Restaura t1 da pilha
    lw t2, 20(sp)          # Restaura t2 da pilha
    lw t3, 24(sp)          # Restaura t3 da pilha
    lw t4, 28(sp)          # Restaura t4 da pilha
    lw a3, 32(sp)          # Restaura a3 da pilha
    lw t5, 36(sp)          # Restaura t5 da pilha
    addi sp, sp, 40        # Ajusta o stack pointer para desalocar espaço dos registos
    jr ra                  # Retorna da função


### updateClusters
# Percorre os pontos, calcula a distancia minima atraves da funcao nearestCluster
# entre o ponto e todos os centroids e associa o ponto ao cluster correto.
# Argumentos: nenhum
# Retorno: nenhum
updateClusters:
    addi sp, sp, -52       # Ajusta o stack pointer para salvar registos
    sw ra, 0(sp)           # Salva o valor de ra
    sw t0, 4(sp)           # Salva t0
    sw t1, 8(sp)           # Salva t1
    sw t2, 12(sp)          # Salva t2
    sw t3, 16(sp)          # Salva t3
    sw t4, 20(sp)          # Salva t4
    sw s10, 24(sp)         # Salva s10
    sw s11, 28(sp)         # Salva s11
    sw a0, 32(sp)          # Salva a0
    sw a1, 36(sp)          # Salva a1
    sw a2, 40(sp)          # Salva a2
    sw t5, 44(sp)          # Salva t5
    sw t6, 48(sp)          # Salva t6
    
    la t0, points          # Endereco do vetor de pontos
    lw t1, n_points        # Numero de pontos
    la t2, centroids       # Endereco dos centroides
    lw t3, k               # Numero de clusters (k)
    la t4, clusters        # Endereco dos clusters

    li t5, 0               # Inicializa o indice do ponto atual

# Loop para percorrer todos os pontos
loop_points:
    bge t5, t1, end_updateClusters  # Se t5 >= n_points, termina o loop

    slli t6, t5, 3         # t6 = t5 * 8 (cada ponto ocupa 2 words)
    add s10, t0, t6        # Endereço do ponto atual
    lw a0, 0(s10)          # Carrega o x do ponto
    lw a1, 4(s10)          # Carrega o y do ponto

    jal nearestCluster     # Chama nearestCluster
    
    slli t6, t5, 2         # t6 = t5 * 4 (cada cluster ocupa 1 word)
    add s11, t4, t6        # Endereço do cluster do ponto atual
    sw a0, 0(s11)          # Associa o ponto ao cluster mais próximo

    addi t5, t5, 1         # Próximo ponto
    j loop_points          # Volta ao início do loop

end_updateClusters:
    lw ra, 0(sp)           # Restaura o valor de ra
    lw t0, 4(sp)           # Restaura t0
    lw t1, 8(sp)           # Restaura t1
    lw t2, 12(sp)          # Restaura t2
    lw t3, 16(sp)          # Restaura t3
    lw t4, 20(sp)          # Restaura t4
    lw s10, 24(sp)         # Restaura s10
    lw s11, 28(sp)         # Restaura s11
    lw a0, 32(sp)          # Restaura a0
    lw a1, 36(sp)          # Restaura a1
    lw a2, 40(sp)          # Restaura a2
    lw t5, 44(sp)          # Restaura t5
    lw t6, 48(sp)          # Restaura t6
    addi sp, sp, 52        # Ajusta o stack pointer para restaurar registos
    jr ra                  # Retorna

ehCentroidsIguais:
    addi sp, sp, -48       # Ajusta o stack pointer para salvar registos
    sw s0, 0(sp)           # Salva s0
    sw s1, 4(sp)           # Salva s1
    sw s2, 8(sp)           # Salva s2
    sw s3, 12(sp)          # Salva s3
    sw s4, 16(sp)          # Salva s4
    sw s5, 20(sp)          # Salva s5
    sw s6, 24(sp)          # Salva s6
    sw s7, 28(sp)          # Salva s7
    sw s8, 32(sp)          # Salva s8
    sw s9, 36(sp)          # Salva s9
    sw s10, 40(sp)         # Salva s10
    sw ra, 44(sp)          # Salva ra
    la s0, centroidsAnteriores # Carrega centroidsAnteriores
    la s1, centroids           # Carrega centroids
    lw s2, k                   # Carrega k
    li s3, 0                   # Inicializa s3 a 0
    Preenchimento:
        beq s3, s2, acabaPreenchimento # Se s3 >= k para de preencher
        slli s4, s3, 3                 # Multiplica o contador por 8 (centroids são de 8 em 8)
        add s5, s1, s4                 # Avança no vetor centroids
        add s6, s0, s4                 # Avança no vetor centroidsAnteriores
        lw s7, 0(s5)                   # Carrega o x dos centroids
        sw s7, 0(s6)                   # Salva o x dos centroids em centroidsAnteriores
        lw s7, 4(s5)                   # Carrega o y dos centroids
        sw s7, 4(s6)                   # Salva o y dos centroids em centroidsAnteriores
        addi s3, s3, 1                 # Soma 1 ao contador
        j Preenchimento                # Repete o preenchimento
    acabaPreenchimento:
        jal calculateCentroids         # Chama a função calculateCentroids
        li a0, 1                       # Define a0 como 1 (default os vetores são iguais)
        li s3, 0                       # Inicializa o contador a 0
    Comparacao:
        beq s3, s2, FimComparacao      # Se s3 >= k, termina a comparação
        slli s4, s3, 3                 # Multiplica o contador por 8 (centroids são de 8 em 8)
        add s5, s1, s4                 # Avança no vetor centroids
        add s6, s0, s4                 # Avança no vetor centroidsAnteriores
        lw s7, 0(s5)                   # Carrega o x dos centroids
        lw s8, 4(s5)                   # Carrega o y dos centroids
        lw s9, 0(s6)                   # Carrega o x do centroid anterior
        lw s10, 4(s6)                  # Carrega o y do centroid anterior
        bne s7, s9, ValorDiferente     # Se os x's forem diferentes, muda a0 para 0 e sai do loop
        bne s8, s10, ValorDiferente    # Se os y's forem diferentes, muda a0 para 0 e sai do loop
        addi s3, s3, 1                 # Incrementa o contador
        j Comparacao                   # Repete a comparação
    ValorDiferente:
        li a0, 0                       # Define a0 como 0 (vetores diferentes)
    FimComparacao:
        lw s0, 0(sp)                   # Restaura s0
        lw s1, 4(sp)                   # Restaura s1
        lw s2, 8(sp)                   # Restaura s2
        lw s3, 12(sp)                  # Restaura s3
        lw s4, 16(sp)                  # Restaura s4
        lw s5, 20(sp)                  # Restaura s5
        lw s6, 24(sp)                  # Restaura s6
        lw s7, 28(sp)                  # Restaura s7
        lw s8, 32(sp)                  # Restaura s8
        lw s9, 36(sp)                  # Restaura s9
        lw s10, 40(sp)                 # Restaura s10
        lw ra, 44(sp)                  # Restaura ra
        addi sp, sp, 48                # Ajusta o stack pointer para restaurar registos
        jr ra                          # Retorna

### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:
    addi sp, sp, -8          # Ajusta o stack pointer para salvar registos
    sw ra, 0(sp)             # Salva ra
    sw t0, 4(sp)             # Salva t0
    jal initializeCentroids  # Chama initializeCentroids
    li t0, 0                 # Inicializa t0 a 0 (contador de iterações)
    lw t1, L                 # Carrega L (número máximo de iterações)
    li t2, 1                 # Define t2 como 1 (flag de convergência)
    loop_main_principal:
        bge t0, t1, fim_main_principal # Se t0 >= L, termina o loop
        beq a0, t2, fim_main_principal # Se a0 == 1 (convergência), termina o loop
        addi sp, sp, -8       # Ajusta o stack pointer para salvar registos
        sw t0, 0(sp)          # Salva t0
        sw t1, 4(sp)          # Salva t1
        jal cleanScreen       # Chama cleanScreen
        jal updateClusters    # Chama updateClusters
        jal printClusters     # Chama printClusters
        jal ehCentroidsIguais # Chama ehCentroidsIguais
        jal printCentroids    # Chama printCentroids
        lw t0, 0(sp)          # Restaura t0
        lw t1, 4(sp)          # Restaura t1
        addi sp, sp, 8        # Ajusta o stack pointer para restaurar registos
        addi t0, t0, 1        # Incrementa o contador de iterações
        j loop_main_principal # Volta ao início do loop
        
    fim_main_principal:
        lw ra, 0(sp)         # Restaura ra
        lw t0, 4(sp)         # Restaura t0
        addi sp, sp, 8       # Ajusta o stack pointer para restaurar registos
        jr ra                # Retorna
