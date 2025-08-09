FROM rocker/r-ver:4.4.1

RUN apt-get update && apt-get install -y libglpk-dev && rm -rf /var/lib/apt/lists/*

RUN Rscript -e "install.packages(c('plumber', 'caret', 'kknn'))"

WORKDIR /api

COPY api.R ./api.R

COPY PrePCA_KNN.rds ./PrePCA_KNN.rds

EXPOSE 8000

CMD ["Rscript", "-e", "library(plumber); pr <- plumb('api.R'); pr$run(host='0.0.0.0', port=8000)"]