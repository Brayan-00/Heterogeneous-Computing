# Laboratorio 2:

## Resumen General

En este laboratorio se evalúa el impacto en el rendimiento al aplicar instrucciones SIMD (*Single Instruction, Multiple Data*) en contraste con ejecuciones escalares secuenciales. La implementación se desarrolló en el lenguaje C sobre un sistema operativo Ubuntu (arquitectura x86_64) utilizando el compilador `gcc` y las funciones intrínsecas de **AVX2**.

---

## Ejercicio A: Multiplicación de Vectores de Punto Flotante

**Objetivo:** Realizar la multiplicación elemento a elemento de dos vectores de precisión simple (`float`) de 1024 elementos.

**Descripción de la implementación:**

* La multiplicación vectorial paralela de 8 elementos simultáneos se ejecutó mediante la instrucción `_mm256_mul_ps(a, b)`.

---

## Ejercicio B: Reducción Horizontal de un Vector (Suma Acumulada)

**Objetivo:** Reducir un vector de 1024 elementos a un único valor escalar mediante la suma de todos sus componentes.

**Descripción de la implementación:**

1. **Extracción:** Se emplearon las instrucciones `_mm256_extractf128_ps(value, 0)` y `_mm256_extractf128_ps(value, 1)` para dividir el registro AVX de 256 bits en dos mitades (low y high, respectivamente) de 128 bits.
2. **Suma Paralela Inicial:** Ambas mitades se sumaron con `_mm_add_ps(low, high)` obteniendo un único registro de 128 bits.
3. **Suma Horizontal:** Se ejecutó dos veces consecutivas la instrucción de suma horizontal `_mm_hadd_ps` sobre el registro de 128 bits para acumular los datos de forma adyacente dentro del mismo registro.
4. **Conversión a Escalar:** Finalmente, se extrajo el resultado escalar de 32 bits utilizando la instrucción `_mm_cvtss_f32`.

---

## Ejercicio C: Multiplicación de Matrices Vectorizada

**Objetivo:** Implementar la multiplicación de matrices aprovechando las rutinas desarrolladas en los ejercicios anteriores.

**Descripción de la implementación:**

* Se optimizó el acceso a memoria transponiendo previamente la segunda matriz para asegurar accesos contiguos por filas.
* Los datos se cargaron secuencialmente en registros vectoriales mediante `_mm256_loadu_ps`.
* El producto punto de los bloques vectoriales se obtuvo mediante la combinación del producto elemento a elemento (Ejercicio A) y la reducción por suma (Ejercicio B).

---

## Ejercicio D: Comparativa de Rendimiento (Vectorizado vs. Escalar)

**Objetivo:** Evaluar cuantitativamente el incremento de rendimiento (*speedup*) al multiplicar matrices de tamaño $2048 \times 2048$ comparando la versión vectorizada con AVX2 (`matmul_avx2`) frente a la versión escalar tradicional (`matmul_scalar`).

### Tabla Comparativa de Resultados

| Métrica / Parámetro | Versión Escalar (`matmul_scalar`) | Versión AVX2 (`matmul_avx2`) | Diferencia / Factor |
| --- | --- | --- | --- |
| **Tamaño de Matriz** | $2048 \times 2048$ | $2048 \times 2048$ | — |
| **Repeticiones** | 2 | 2 | — |
| **Operaciones Flotantes** | 34,359,738,368 ($34.36 \text{ GFLOP}$) | 34,359,738,368 ($34.36 \text{ GFLOP}$) | 0% (Validación) |
| **Checksum (Verificación)** | $86,972,906,452.00$ | $86,972,906,452.00$ | Idéntico (Correcto) |
| **C[0][0]** | $26,800.50$ | $26,800.50$ | Idéntico |
| **C[1023][1023]** | $26,836.50$ | $26,836.50$ | Idéntico |
| **Tiempo de Ejecución** | **24.385 s** | **11.414 s** | **Reducción del 53.19%** |
| **Rendimiento (GFLOP/s)** | **1.409 GFLOP/s** | **3.010 GFLOP/s** | **Aumento de 2.13x** |

### Análisis de Resultados

* **Aceleración (*Speedup*):** La versión vectorizada `matmul_avx2` reduce el tiempo de cómputo a menos de la mitad, logrando una aceleración de aprox. **2.13x** (de 1.41 GFLOP/s a 3.01 GFLOP/s).
* **Correctitud:** Los valores de *Checksum*, así como las muestras en la matriz resultado ($C[0][0]$ y $C[1023][1023]$), son numéricamente idénticos en ambos programas, garantizando la precisión del cálculo vectorizado.

---

## Información General

### Autor

Brayan Rodríguez Villalobos

### Curso

Introducción a la Computación Heterogénea - EL-5859

### Profesor

Dr. Luis G. León-Vega

---

## Referencias

[1] Intel Corporation, *Intel® Intrinsics Guide*. [En línea]. Disponible en: [https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html](https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html)

## IA

La documentación de este laboratorio se realizó con apoyo de inteligencia artificial.

[https://share.gemini.google/tijAx9F1qnqj](https://share.gemini.google/tijAx9F1qnqj)