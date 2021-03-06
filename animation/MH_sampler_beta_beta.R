## Alvo: Beta.
## Canditada: Uniforme.
mhsampler2 <- function(nsim, x1, plot=FALSE,
                       go=c("click","enter","none")){
    out <- vector(mode="numeric", length=nsim)
    ## Valor para iniciar a cadeia.
    out[1] <- x1
    for(i in 2:nsim){
        ## Realização da distribuição alvo.
        if(plot & go[1]=="click"){
            y <- locator(n=1)$x
        } else {
            y <- rbeta(1, 2, 6)
        }
        ## Cálculo da razão de aceitação.
        ## num <- f(y, sigma) * dchisq(x[i - 1], df = y)
        ## den <- f(x[i - 1], sigma) * dchisq(y, df = x[i - 1])
        dg1 <- dbeta(y, 2.7, 6.3)
        dn1 <- dbeta(out[i - 1], 2, 6)
        dg0 <- dbeta(out[i-1], 2.7, 6.3)
        dn0 <- dbeta(y, 2, 6)
        ratio <- (dg1 * dn1)/(dg0 * dn0)
        u <- runif(1)
        if(u<ratio){
            ## Se sim, cadeia ganha novo valor.
            out[i] <- y
        } else {
            ## Se não, cadeia recebe o último.
            out[i] <- out[i-1]
        }
        ## Parte de representação gráfica do método.
        if(plot & nsim<=20){
            ## Curvas.
            curve(dbeta(x, 2.7, 6.3), 0, 1, ylim=c(0, 3),
                  ylab="densidade");
            curve(dbeta(x, 2, 6), add=TRUE, lty=2);
            ## Lengendas.
            legend("topright",
                   legend=c(expression(f*" ~ Beta"),
                       expression(g*" ~ Beta(2,6)")),
                   lty=c(1,2), bty="n")
            legend("right",
                   legend=c(expression("Candidato em"*~t + 1),
                       expression("Valor em"*~t)),
                   lty=1, col=c(2,4), bty="n")
            ## Segmentos da base até os valores nas funções.
            ## segments(y, dg1, y, 0, col=2, lty=1);
            ## segments(y, dn1, y, 0, col=2, lty=1);
            ## segments(out[i-1], dg0, out[i-1], 0, col=4, lty=1);
            ## segments(out[i-1], dn0, out[i-1], 0, col=4, lty=1);
            segments(y, dg1, y, 0, col=2, lty=1);
            segments(out[i - 1], dn1, out[i - 1], 0, col=4, lty=1);
            segments(out[i-1], dg0, out[i-1], 0, col=4, lty=1);
            segments(y, dn0, y, 0, col=2, lty=1);
            ## Pontos sobre as funções.
            cex <- 2.5; col="yellow"
            points(y, dg1, pch=19, cex=cex, col="green");
            points(out[i - 1], dn1, pch=19, cex=cex, col=col);
            points(out[i-1], dg0, pch=19, cex=cex, col="green");
            points(y, dn0, pch=19, cex=cex, col=col);
            ## Rótulos dos pontos.
            text(y, dg1, labels=expression(f[Y]));
            text(out[i - 1], dn1, labels=expression(g[X]));
            text(out[i-1], dg0, expression(f[X]));
            text(y, dn0, expression(g[Y]));
            text(c(y, out[i-1]), 0,
                 labels=c(expression(x[t + 1]), expression(x[t])),
                 pos=4)
            ## Anotações matemáticas.
            L <- list(dg1=dg1, dg0=dg0, dn1=dn1,
                      dn0=dn0, num=dg1 * dn1, den=dg0 * dn0,
                      ratio=ratio)
            L <- lapply(L, round, digits=3)
            ## ex <- substitute(frac(f[X](x[i]), f[X](x[i-1]))/
            ##                  frac(f[Y](x[i]), f[Y](x[i-1]))*" = "*
            ##                  frac(dg1, dg0)/frac(dn1, dn0)*" = "*
            ##                  num/den==ratio, L)
            ex <- substitute(
                frac(f(y) * g(x[t] * "|" * y),
                     f(x[t]) * g(y * "|" * x[t]))*" = "*
                frac(dg1, dg0) ~ frac(dn1, dn0)*" = "*
                    frac(num, den) == ratio, L)
            r <- substitute("u = "~u<ratio,
                            lapply(list(ratio=ratio, u=u),
                                   round, digits=3))
            mtext(ex, side=3, line=1, adj=0)
            mtext(r, side=3, line=2, adj=1)
            mtext(ifelse(u<ratio,
                         expression(Aceita~x[t + 1]),
                         expression(Repete~x[t])),
                  side=3, line=1, adj=1)
            switch(go[1],
                   ## Avança por cliques do mouse.
                   click=locator(n=1),
                   ## Avança por enter no console.
                   console=readline(prompt="Press [enter] to continue"),
                   ## Avança com intervalo de tempo entre etapas.
                   none=Sys.sleep(0.5))
        }
    }
    return(out)
}

n <- 10
x <- mhsampler2(n, x1 = .5, plot=TRUE, go="console")

## Gerando muitos números pelo método.
x <- mhsampler2(5000, x1 = .5)
par(mfrow=c(2,2))
plot(x, type="l")        ## Traço da cadeia completa.
plot(x[1:100], type="l") ## Traço do começo da cadeia.
acf(x)                   ## Mostra que a cadeia não é independente.
plot(ecdf(x))            ## Acumulada teórica vs empírica.
curve(pbeta(x, 2.7, 6.3), add = TRUE, col = 2, from = 0)
par(mfrow=c(1,1))

animation::saveHTML(
               mhsampler2(nsim = 20, x1 = .2,
                          plot = TRUE, go = "none"),
               img.name = "MH_sampler_beta_beta",
               imgdir = "figures/MH_sampler_beta_beta",
               htmlfile = "MH_sampler_beta_beta.html",
               autobrowse = FALSE,
               verbose = FALSE,
               ani.width = 600,
               ani.height = 600)


##======================================================================
## Aceitação-rejeição --------------------------------------------------
## Define funções
f <- function(x) dbeta(x, 2.7, 6.3)
g <- function(x) dbeta(x, 2, 6)
## Máximo M
(M <- optimize(f = function(x) {f(x)/g(x)},
               interval = c(0, 1), maximum = TRUE)$objective)
curve(f, from = 0, to = 1, col = 4)
curve(g, from = 0, to = 1, add = TRUE, lty = 2)
curve(M * g(x), add = TRUE, lty = 2, lwd = 2)
legend("right", legend = c("f(x)", "g(x)", "M g(x)"),
       lty = c(1, 2, 2), col = c(4, 1, 1), lwd = c(1, 1, 2), bty = "n")
## Simula com número fixo
N <- 1e5
## Amostra da proposta U(0,1)
y <- rbeta(N, 2, 6)
## Amostra u também de U(0,1)
u <- runif(N)
## Calcula a razão
r <- f(y)/(M * g(y))
## x serão os valores de y onde u < r
x.ar <- y[u < r]
## Aceitados
ua <- u[u < r]

## Metropolis-Hastings -------------------------------------------------
## Simula com número fixo
N <- 1e5
x <- numeric(N)
x[1] <- rbeta(1, 2, 6)
k <- 0 # para contar quantos foram aceitos
for (i in 2:N) {
    y <- rbeta(1, 2, 6)
    num <- f(y) * g(x[i - 1])
    den <- f(x[i - 1]) * g(y)
    alpha <- num/den
    u <- runif(1)
    if (u <= alpha) {
        x[i] <- y
    } else {
        x[i] <- x[i - 1]
        k <- k + 1     # contagem doa aceitos
    }
}


## Taxa de aceitação - AR
1/M # teórica
length(ua)/N
## Taxa de aceitação - MH
k/N
## Compara amostras com acumulada teórica
par(mfrow = c(1, 2))
plot(ecdf(x.ar), main = "Aceitação-rejeição")
curve(pbeta(x, 2.7, 6.3), add = TRUE, from = 0, to = 1, col = 2)
plot(ecdf(x), main = "Metropolis-Hastings")
curve(pbeta(x, 2.7, 6.3), add = TRUE, from = 0, to = 1, col = 2)
legend("right", legend = c("Empírica", "Teórica"),
       lty = 1, col = 1:2, bty = "n")
## Compara autocorrelação
acf(x.ar, main = "Aceitação-rejeição")
acf(x, main = "Metropolis-Hastings")
## Compara as duas cadeias
par(mfrow = c(2, 1))
plot.ts(x.ar[5000:5200], main = "Aceitação-rejeição")
plot.ts(x[5000:5200], main = "Metropolis-Hastings")
par(mfrow = c(1, 1))
