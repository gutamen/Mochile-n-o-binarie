import matplotlib.pyplot as plt
import numpy as np

plt.figure(figsize=(10,7.5))

# Crie um vetor de dados para o eixo x
x_data = [10, 50, 100, 200, 300, 500, 750, 1000, 1250, 1500, 2000, 2500, 3000, 4000, 5000]
# Crie quatro vetores de dados para o eixo y
y_bin = [48775.4, 62165.8, 67791.6, 79771.8, 110200.6, 161536, 270374.2, 425338.2, 713023.2, 875678, 1515131.6, 2346942, 3502834, 6260971.8, 9296145.4]


y_frac = [46833.4, 61401.4, 69205.8, 83567.8, 105136.6, 166526, 295088.6, 423111.6, 681553.2, 926234.6, 1516144, 2538538, 3509346.2, 6043755.6, 9145943.2]

# Crie um gráfico de linhas com quatro linhas
plt.plot(x_data, y_bin, label="Binária")
plt.plot(x_data, y_frac, label="Fracionária")
plt.xticks([ 100, 200, 300, 500, 1000, 2000, 3000, 4000, 5000], rotation=70)
plt.yticks(np.arange(0, 9000001, step=500000))
plt.ticklabel_format(style='plain')
plt.tight_layout()

# Configure o label do eixo x
plt.xlabel("Quantidade de itens disponíveis")

# Configure o label do eixo y
plt.ylabel("Tempo de execução em Nanosegundos")

plt.xlim(x_data[0], x_data[-1])
plt.subplots_adjust(left=0.1, right=0.988, top=0.992, bottom=0.13)
# Configure as cores das linhas
#plt.legend(loc="upper left", colors=["red", "green", "blue", "yellow"])




# Mostre o gráfico
plt.legend()
plt.show()
