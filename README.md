# koigrid-ci-bench

Medición pública de velocidad de runners de CI: la misma carga (la suite de [Hono](https://github.com/honojs/hono)
`v4.7.0`: `tsc --noEmit` y `vitest --run`) en un `ubuntu-latest` de GitHub Actions y en una VM de koigrid.
`bench.sh` imprime una línea JSON por medida; la instalación de dependencias se mide aparte porque depende de la red.
