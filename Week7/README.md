# Laboratorio Semana 7

## suma de vectores
Este programa busca calcular la suma de dos vectores. El resultado es un vector `C` del mismo tamaño `N` , donde cada posición `i` almacena la suma de los elementos $A[i]$ y $B[i]$.

### Preguntas

1. ¿Cuántos bloques se lanzan cuando N = 1048576 y cada bloque tiene 256 hilos?

    Sea N el tamaño del vector, B el número de bloques y H el número de hilos por bloque la fórmula que garantiza que existan suficientes hilos para cubrir todo el vector es la siguiente:

    $ B = \frac{N + H - 1}{H}$

    Sustituyendo los valores:

   $$B = \frac{1048576 + 256 - 1}{256} = \frac{1048831}{256} = 4096.996 \xrightarrow{\text{división entera}} 4096 \text{ bloques}$$

   Como $N$ ($1048576$) es un múltiplo exacto de $256$, se lanzan exactamente **4096 bloques**, generando $4096 \times 256 = 1048576$ hilos totales (exactamente 1 hilo por elemento).

2. ¿Qué ocurre si N no es múltiplo del tamaño del bloque?

    La división no es entera, entonces van a haber hilos dentro del último bloque que no son utilizados para esa tarea. Si se eligen menos bloques se dejarían por fuera múltiples elementos del vector.

3. ¿Qué transferencias de memoria ocurren entre CPU y GPU?

    Se realizan 3 transferencias de memoria principal mediante la API de CUDA:
   * **Host a Device (CPU $\rightarrow$ GPU):** 2 transferencias de entrada (`cudaMemcpyHostToDevice`) para enviar los vectores $A$ y $B$ a la VRAM.
   * **Device a Host (GPU $\rightarrow$ CPU):** 1 transferencia de salida (`cudaMemcpyDeviceToHost`) para copiar el vector resultante $C$ de vuelta a la memoria RAM.

### Salida del programa

Utilizando LeetGPU se obtuvo el siguiente resultado:

```bash 
Running in FUNCTIONAL mode...
Compiling...
Executing...
vector-add n=1048576: OK
Exit status: 0
```
``` bash
Running in FUNCTIONAL mode...
Compiling...
Executing...
vector-add n=2097152: OK
Exit status: 0
```

## producto punto

El propósito general del programa es calcular el producto punto de dos vectores dados. Se identifican dos secciones que deben ser implementadas. La primera donde se realiza la multiplicación de los elementos de los vectores, aprovechando la paralelización que ofrece. Y la segunda realiza la acumulación de los resultados obtenidos, en esta parte se aplica una lógica en la que se suman dos valores con una distancia definida como `stride`.

### Preguntas

1. ¿Por qué este ejercicio no puede resolverse solamente escribiendo un valor independiente por
hilo?

    Se debe a que el cálculo del producto punto requiere que se realice una reducción. La primer parte donde se realiza la multiplicación $A[i] \cdot B[i]$ puede ser realizada por hilos independientes, pues no se requiere del resultado de otro hilo. Lo que sí pasa en la segunda parte donde se suman los resultados. Se ocupa que estén calculados y escritos todos los valores del vector que se va a reducir(sumar todos sus elementos).

2. ¿Cuántos valores parciales se copian de GPU a CPU?

    Se copia el elemento 0 del vector resultante de la reducción. Esto sucede en cada bloque, lo que implica que se copia un dato de GPU a CPU por bloque. Y la cantidad de bloques está definida en el código por:

    ``` c
    int blocks = (n + threads_per_block - 1) / threads_per_block;
    ```

3. ¿Qué pasaría si se elimina alguna sincronización dentro de la reducción?
    El propósito de la sincronización es esperar que todos los hilos terminen la operación que estén realizando. De esta manera se espera a que todos los resultados estén listos. Dentro de la reducción si no se realiza la sincronización puede que se realicen operaciones con datos no actualizados, lo que invalidaría el resultado obtenido.

### Salida del programa

Utilizando LeetGPU se obtuvo el siguiente resultado:

```bash 
Running in FUNCTIONAL mode...
Compiling...
Executing...
dot-product n=1048576: gpu=-21.250000 cpu=-21.250000 error=0.000000 OK
Exit status: 0
```


``` bash
Running in FUNCTIONAL mode...
Compiling...
Executing...
dot-product n=4194304: gpu=-0.500000 cpu=-0.500000 error=0.000000 OK
Exit status: 0
```

## softmax

La función softmax toma un vector como entrada y lo normaliza en una distribución de probabilidades.
Sigue la siguiente ecuación:

$y_{r,c} = \frac{e^{x_{r,c} - m_r}}{\sum_{j=0}^{cols-1} e^{x_{r,j} - m_r}}, \quad m_r = \max_j x_{r,j}$

### Preguntas

1. ¿Por qué se calcula primero el máximo de cada fila?

    Porque el algoritmo evita que se deba realizar al calculo de la exponencial de un número muy grande, ya que esto puede incurrir en errores de overflow. Por esto es que se resta este valor en el exponente de la funcion exponencial. 

2. ¿Qué partes del algoritmo requieren cooperación entre hilos del mismo bloque?
    El cálculo del máximo se realiza utilizando el concepto de `stride`, esto hace la comparación de dos elementos del vector. Esto genera una reducción del vector a la mitad de su tamaño. Cuando se realiza esta comparación por segunda vez se requiere que se haya finalizado el cálculo de los datos anteriores. 
    Esta dependencia de datos hace que se requiera una cooperación entre hilos y además una necesidad de sincronización.

    Esta situación también se presenta en la reducción de la suma de los resultados de las exponenciales. De igual manera se utiliza el concepto de `stride` y se requiere sincronización para no operar la suma sobre datos no actualizados.

3. ¿Qué limitación tiene usar un solo bloque por fila cuando cols crece mucho?

    Se alcanza el límite físico de hilos dentro de ese bloque, esto significa que los hilos deben operar sobre múltiples columnas. Esto agrega latencia al proceso y reduce el speedup generado por la paralelización. 
### Salida del programa

Utilizando LeetGPU se obtuvo el siguiente resultado:

```bash 
Running in FUNCTIONAL mode...
Compiling...
Executing...
softmax rows=128 cols=1024: OK
Exit status: 0
```

``` bash
Running in FUNCTIONAL mode...
Compiling...
Executing...
softmax rows=256 cols=2048: OK
Exit status: 0
```

## Descripción del Hardware

Se hizo uso de la herramienta LeetGPU en su modo `Functional` con una GPU NVIDIA GTX TITAN X

## Referencias y Herramientas

[CUDA](https://docs.nvidia.com/cuda/cuda-programming-guide/index.html)

[LeetGPU](https://leetgpu.com/playground)

[Softmax](https://en.wikipedia.org/wiki/Softmax_function)



---

## Información General

### Autor

Brayan Rodríguez Villalobos

### Curso

Introducción a la Computación Heterogénea - EL-5859

### Profesor

Dr. Luis G. León Vega

---

## IA

El desarrollo de este laboratorio se realizó con el apoyo de herramientas que utilizan inteligencia artificial, tales como chatbots y el motor de búsqueda de Google. Se utiliza para comprender conceptos y el funcionamiento del código, así como mejorar de redacción y corregir formatos.

[gemini](https://share.gemini.google/kqO4F4xt1E86)
