# jlsd
# escenarios a un año con bootstrap estacionario, solo R base

args <- commandArgs(trailingOnly = TRUE)
entrada <- if (length(args) >= 1) args[1] else "datos/procesados/escenarios entrada.csv"
salida <- if (length(args) >= 2) args[2] else "resultados"
capital <- if (length(args) >= 3) as.numeric(args[3]) else 100000
nsim <- if (length(args) >= 4) as.integer(args[4]) else 10000L
horizonte <- if (length(args) >= 5) as.integer(args[5]) else 252L
bloque <- if (length(args) >= 6) as.numeric(args[6]) else 21

set.seed(20261121)
df <- read.csv(entrada, check.names = FALSE)
carteras <- setdiff(names(df), "Fecha")
nhist <- nrow(df)

# indices de los dias simulados, por bloques de un mes en promedio
idx <- matrix(0L, nsim, horizonte)
idx[, 1] <- sample.int(nhist, nsim, replace = TRUE)
for (d in 2:horizonte) {
  nuevo <- runif(nsim) < 1 / bloque
  idx[, d] <- ifelse(nuevo, sample.int(nhist, nsim, replace = TRUE), idx[, d - 1] %% nhist + 1L)
}

# valor acumulado de cada trayectoria
trayectorias <- function(r) {
  m <- matrix(r[idx], nsim, horizonte)
  v <- matrix(0, nsim, horizonte)
  v[, 1] <- 1 + m[, 1]
  for (d in 2:horizonte) v[, d] <- v[, d - 1] * (1 + m[, d])
  v
}

# peor caida dentro del año
caidamaxima <- function(v) {
  pico <- v[, 1]
  peor <- pmin(0, v[, 1] - 1)
  for (d in 2:horizonte) {
    pico <- pmax(pico, v[, d])
    peor <- pmin(peor, v[, d] / pico - 1)
  }
  peor
}

caminos <- lapply(setNames(carteras, carteras), function(k) trayectorias(df[[k]]))
ref <- if ("Solo CETES" %in% carteras) caminos[["Solo CETES"]][, horizonte] else NULL
probs <- c(0.05, 0.25, 0.5, 0.75, 0.95)

# bandas para la grafica
bandas <- do.call(rbind, lapply(carteras, function(k) {
  q <- apply(caminos[[k]], 2, quantile, probs = probs)
  data.frame(cartera = k, dia = 1:horizonte, p05 = capital * q[1, ], p25 = capital * q[2, ],
             p50 = capital * q[3, ], p75 = capital * q[4, ], p95 = capital * q[5, ])
}))

# resumen por cartera
resumen <- do.call(rbind, lapply(carteras, function(k) {
  fin <- caminos[[k]][, horizonte]
  dd <- caidamaxima(caminos[[k]])
  data.frame(cartera = k, mediana = capital * median(fin), p05 = capital * quantile(fin, 0.05),
             p95 = capital * quantile(fin, 0.95), probperdida = mean(fin < 1),
             probcetes = if (is.null(ref) || k == "Solo CETES") NA else mean(fin > ref),
             caidamediana = median(dd), caidamala = quantile(dd, 0.05))
}))
rownames(resumen) <- NULL

meta <- data.frame(clave = c("rversion", "simulaciones", "horizonte", "bloque", "desde", "hasta", "autor"),
                   valor = c(R.version.string, nsim, horizonte, bloque, df$Fecha[1], df$Fecha[nhist], "jlsd"))

dir.create(salida, showWarnings = FALSE, recursive = TRUE)
write.csv(bandas, file.path(salida, "escenarios bandas.csv"), row.names = FALSE)
write.csv(resumen, file.path(salida, "escenarios resumen.csv"), row.names = FALSE)
write.csv(meta, file.path(salida, "escenarios meta.csv"), row.names = FALSE)
cat(sprintf("Escenarios listos: %d carteras, %d simulaciones de %d dias\n", length(carteras), nsim, horizonte))
