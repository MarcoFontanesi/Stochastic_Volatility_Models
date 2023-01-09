data {
  int<lower=0> N_t;  // Number of time points (equally spaced)
  vector[N_t] y;    // mean corrected response at time t
}

parameters {
  real mu;                     // mean log volatility
  real<lower=-1, upper=1> phi; // persistence of volatility
  real<lower=0> sigma;         // white noise shock scale
  vector[N_t] h_std;           // standardised log volatility at time t
}

transformed parameters {
  vector[N_t] h;               // log volatility at time t
  
  h = h_std*sigma; //now h ~ normal(0, sigma)
  h[1] = h[1] / sqrt(1-phi * phi); //rescale h[1] ~ normal(mu, sigma/sqrt(1-phi * phi))
  h = h + mu;      //h[2] through h[t] are now distributed normal(mu, sigma)
  
  for (t in 2:N_t)
    h[t] = h[t] + phi * (h[t-1] - mu); //h[2] through h[t] are now distributed normal(mu + phi * (h[t - 1] -  mu), sigma)
}

model {
// Priors distributions of our parameters  
  phi ~ uniform(-1,1);
  sigma ~ cauchy (0,5);
  mu ~ cauchy(0, 10);
  h_std ~ normal(0, 1);
  
// Likelihood  
  //h[1] ~ normal(mu, sigma / sqrt(1 - phi * phi));
  //for (t in 2:N_t) {
  //h[t] ~ normal(mu + phi * (h[t - 1] -  mu), sigma);
  //}
  //
  //for (t in 1:N_t) {
  //y ~ normal(0, exp(h[t] / 2));
  //}
  y ~ normal(0, exp(h/2));
}

generated quantities {
  vector[N_t] y_rep;
  
  for (t in 1:N_t){
    y_rep[t] = normal_rng(0, exp(h[t]/2));
  }
  
}
