claer all;
clc;

riskfree = xlsread("USD1MTD156N.xlsx",['B2:B121']);

AAPL = csvread("AAPL.csv",1,0,[1,1,121,7]);
AAPL_price = csvread("AAPL.csv",1,0,[1,1,121,1]);
AAPL_return = AAPL_price(2:121) / AAPL_price(1:120) - 1;
AAPL_excessReturn = AAPL_return - riskfree;

T = csvread("T.csv",1,0,[1,1,121,7]);
T_price = csvread("T.csv",1,0,[1,1,121,1]);
T_return = T_price(2:121) / T_price(1:120) - 1;
T_excessReturn = T_return - riskfree;

gs = csvread("gs.csv",1,0,[1,1,121,7]);
gs_price = csvread("gs.csv",1,0,[1,1,121,1]);
gs_return = gs_price(2:121) / gs_price(1:120) - 1;
gs_excessReturn = gs_return - riskfree;

aep = csvread("aep.csv",1,0,[1,1,121,7]);
aep_price = csvread("aep.csv",1,0,[1,1,121,1]);
aep_return = aep_price(2:121) / aep_price(1:120) - 1;
aep_excessReturn = aep_return - riskfree;

aet = csvread("aet.csv",1,0,[1,1,121,7]);
aet_price = csvread("aet.csv",1,0,[1,1,121,1]);
aet_return = aet_price(2:121) / aet_price(1:120) - 1;
aet_excessReturn = aet_return - riskfree;
%Find optimal portfolios

%Basic settings
T = 10 * 12 - 1  ;
N = 5  ;
RA = 4 ;
lambda = 1 / RA;

excessReturn = [AAPL_excessReturn, aet_excessReturn, T_excessReturn, gs_excessReturn, aep_excessReturn];

excessReturn_inSmpl= excessReturn(1 : 60 );
excessReturn_oSmpl =excessReturn(60 : 119 );

allReturn = [AAPL_excessReturn, aet_excessReturn, T_excessReturn, gs_excessReturn, aep_excessReturn, riskfree]; %Including the risk-free rate
allReturn.inSmpl = allReturn(1 : 60 );
allReturn.oSmpl = allReturn(60 : 119);

% Unbiased and MLE
cov.smpl <- var(excessReturn.inSmpl)
cov.mle <- cov.smpl * (T - 1)/T 
mean.smpl <- colMeans(excessReturn.inSmpl)
x <- solve(cov.mle, mean.smpl) # inverse(cov.mle) %*% mean.smpl

w.mle <- lambda * x
w0.mle <- 1 - sum(w.mle)

w.unbsd <- w.mle * (T-N-2)/T
w0.unbsd <- 1 - sum(w.unbsd)

% James-Stein shrinkage estimate
u0 <- mean(mean.smpl);
alpha <- min(1,(N-2)/T/(sum((mean.smpl-u0)*(T-N-2)/T*solve(cov.mle,mean.smpl-u0))))
mean.JS <- (1-alpha)*mean.smpl + alpha*u0
w.JS <- lambda*(T-N-2)/T*solve(cov.mle,mean.JS)
w0.JS <- 1-sum(w.JS)

%Jorion Estimator
y <- (T-N-2)/T * solve(cov.mle,rep(1,N))
w.mv <- y / sum(y)
eta <- sum(mean.smpl * w.mv)
alpha <- (N+2)/(N+2 + T*sum((mean.smpl-eta)*(T-N-2)/T*solve(cov.mle,mean.smpl-eta)))
mean.Jrn <- (1-alpha)*mean.smpl + alpha*eta
w.Jrn <- lambda * (T-N-2)/T * solve(cov.mle,mean.Jrn)
w0.Jrn <- 1-sum(w.Jrn)

% Optimal portfolios summary
optml.ptfls <- matrix(c(c(w.unbsd, w0.unbsd), c(w.mle, w0.mle), c(w.JS, w0.JS), 
                        c(w.Jrn, w0.Jrn), rep(1/(N+1), N + 1)), nrow = N + 1)
colnames(optml.ptfls) <- c('unbsd', 'mle', 'JS', 'Jrs', '1/N')
rownames(optml.ptfls) <- c('AAPL', 'AET', 'T', 'GS', 'AEP', 'Risk Free')

%Conduct static out-of-sample test
pfmce.oSmpl <- matrix(, nrow = 4, ncol = ncol(optml.ptfls))
colnames(pfmce.oSmpl) <- c('unbsd', 'mle', 'JS', 'Jrs', '1/N')
rownames(pfmce.oSmpl) <- c('Mean Excess Return', 'Std Excess Return', 'Sharpe Ratio', 'Objective Value')
for(i in 1 : ncol(pfmce.oSmpl))
{
  pfmce.oSmpl[1, i] <- mean(allReturn.oSmpl %*% optml.ptfls[, i])
  pfmce.oSmpl[2, i] <- var(allReturn.oSmpl %*% optml.ptfls[, i])
  pfmce.oSmpl[3, i] <- pfmce.oSmpl[1, i] / pfmce.oSmpl[2, i]
  pfmce.oSmpl[4, i] <- lambda * pfmce.oSmpl[1, i] - 0.5*pfmce.oSmpl[2, i]^2
}

% plot____________________________________________________________________________
plot(cumsum(allReturn.oSmpl %*% optml.ptfls[, ncol(pfmce.oSmpl)]), type = 'l', ylim = c(-1.1, 1.7), xlab = 'period', ylab = 'performances')
for(i in 1 : ncol(pfmce.oSmpl) - 1)
  lines(cumsum(allReturn.oSmpl %*% optml.ptfls[, i]), col = i + 1)





