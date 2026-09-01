# ============================================
# Configuration
# ============================================

set terminal pngcairo size 1000,700 enhanced font "Arial,12"

set grid
set xtics 1
set xrange [0.5:4.5]

# Obtain the execution time with one thread
stats "datos.dat" using 2 every ::0::0 nooutput
T1 = STATS_min


# ============================================
# Execution time
# ============================================

set output "img/execution_time.png"

set title "Tiempo de ejecución respecto al número de hilos"

set xlabel "Número de hilos"
set ylabel "Tiempo de ejecución (s)"

set key off

plot "datos.dat" using 1:2 \
    with linespoints linewidth 2 pointtype 7 pointsize 1.5


# ============================================
# Speedup
# ============================================

set output "img/speedup.png"

set title "Speedup respecto al número de hilos"

set xlabel "Número de hilos"
set ylabel "Speedup"

set key off

plot "datos.dat" using 1:(T1/$2) \
    with linespoints linewidth 2 pointtype 7 pointsize 1.5


# ============================================
# Efficiency
# ============================================

set output "img/efficiency.png"

set title "Eficiencia respecto al número de hilos"

set xlabel "Número de hilos"
set ylabel "Eficiencia"

set key off

plot "datos.dat" using 1:(T1/($1*$2)) \
    with linespoints linewidth 2 pointtype 7 pointsize 1.5