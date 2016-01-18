#!/usr/bin Rscript
# Text mining fuer den IKEA-Katalog
# hier: auf Basis von Text mining and word cloud fungesammttals in R
#

library(tm)
library(SnowballC)
library(RColorBrewer)
library(wordcloud)


setwd("/home/wei/Dropbox/Master Arbeit/reviewMA/Analyse_amazon") 
pdf("gesammt_de.pdf")
# setwd("F:/FP_Data_Mining/R")
sink("gesammt_de.txt", append=TRUE)
Daten <-read.csv("gesammt_de.csv", header=TRUE,fileEncoding = "UTF-8", sep = ",")
n=dim(Daten)[1]

###
### Select comments
###
Comments <- matrix(1,n,1)
for (i in 1:n){
  if (Daten[i,6]>=0){  
    Comments[i]=paste(Daten[i,7],Daten[i,8]) 
                    }
              }
###
### Load the text
###
docs <- Corpus(VectorSource(Comments))
# inspect(docs)

###
### Text transformation
###
toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
docs <- tm_map(docs, toSpace, "/")
docs <- tm_map(docs, toSpace, "@")
docs <- tm_map(docs, toSpace, "\\|")

###
### Cleaning the text
###
# Convert the text to lower case
docs <- tm_map(docs, content_transformer(tolower))

# Remove numbers
docs <- tm_map(docs, removeNumbers)

# Remove common stopwords
docs <- tm_map(docs, removeWords, stopwords("german"))

# Remove your own stop word
# specify your stopwords as a character vector
docs <- tm_map(docs, removeWords, c("schon", "blabla2")) 

# Remove punctuations
docs <- tm_map(docs, removePunctuation)

# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)

# Sichern der ursprünglichen Wörter
tdm <- TermDocumentMatrix(docs)
dictCorpus = Terms(tdm)

# Text stemming
docs <- tm_map(docs,stemDocument,language="german")

###
### Build a term-document matrix
###
dtm <- TermDocumentMatrix(docs, control = list(minWordLength = 1))

# Stemming Completion in TermDocumentMatrix
nTerms = dtm$nrow
for (i in 1:nTerms)
 {Term=dtm$dimnames[1]$Terms[i]
  Term_complete=as.vector(stemCompletion(Term,dictionary=dictCorpus,type="prevalent"))
  if (is.na(Term_complete)) {Term_complete=Term_complete} 
  else {dtm$dimnames[1]$Terms[i]=Term_complete}
 }
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 10)
# inspect(dtm)

###
### Generate the Word cloud
###
set.seed(1234)
wordcloud(words = d$word, freq = d$freq, min.freq = 6,
          max.words=200, random.order=TRUE, rot.per=0.35)

###
### Explore frequent terms and their associations
###
findFreqTerms(dtm, lowfreq = 15)
findAssocs(dtm,'kauf',0.10)

###
### Plot word frequencies
### 
## Find a range of y's that'll leave sufficient space above the tallest bar
ylim <- c(0, 1.1*max(d[1:10,]$freq))
## Plot, and store x-coordinates of bars in xx
xx<-barplot(d[1:10,]$freq, las = 2, names.arg = d[1:10,]$word, ylim = ylim,
        col ="lightblue", main ="Most frequent words",
        ylab = "Word frequencies")
## Add text at top of bars
text(x = xx, y = d[1:10,]$freq, label = d[1:10,]$freq, pos = 3, cex = 1.1, col = "red")

###
### Clustering
###
myTdm <- dtm
# remove sparse terms
myTdm2 <- removeSparseTerms(myTdm, sparse=0.75)
m2 <- as.matrix(myTdm2)
# cluster terms
distMatrix <- dist(scale(m2))
fit <- hclust(distMatrix, method="complete")
plot(fit)
# cut tree into 10 clusters  
rect.hclust(fit, k=5)
(groups <- cutree(fit, k=6))


###
### transpose the matrix to cluster documents
###
m3 <- t(m2)
# set a fixed random seed
set.seed(122)
# k-means clustering of tweets
k <- 8
kmeansResult <- kmeans(m3, k)
# cluster centers
round(kmeansResult$centers, digits=3)

for (i in 1:k) {
  cat(paste("cluster ", i, ":  ", sep=""))
  s <- sort(kmeansResult$centers[i,], decreasing=T)
  cat(names(s)[1:3], "\n")
}


library(fpc)
# partitioning around medoids with estimation of number of clusters
pamResult <- pamk(m3, metric="manhattan")
# number of clusters identified
(k <- pamResult$nc)
pamResult <- pamResult$pamobject
# print cluster medoids
for (i in 1:k) {
  cat(paste("cluster", i, ":  "))
  cat(colnames(pamResult$medoids)[which(pamResult$medoids[i,]==1)], "\n")
}

# plot clustering result
##layout(matrix(c(1,2),2,1)) # set to two graphs per page 
layout(matrix(c(1,2),1,1))
plot(pamResult, color=F, labels=4, lines=0, cex=.8, col.clus=1,
     col.p=pamResult$clustering)
layout(matrix(1)) # change back to one graph per page 
pamResult2 <- pamk(m3, krange=2:8, metric="manhattan")

###
### Correlation graph
###
# source("http://bioconductor.org/biocLite.R")
# biocLite("Rgraphviz")
library(Rgraphviz)

plot(myTdm2,terms=findFreqTerms(myTdm2,lowfreq=200),corThreshold=0.2)

###
### Erweiterung: Social Nework Analysis (from Data Mining with R)
###

termDocMatrix <- myTdm2
termDocMatrix[5:10,1:20]
termDocMatrix <- as.matrix(termDocMatrix)

###
### Transform Data into a Adjacency Matrix
###

# change it to a Boolean matrix
termDocMatrix[termDocMatrix>=1] <- 1
# transform into a term-term adjacency matrix
termMatrix <- termDocMatrix %*% t(termDocMatrix)
# inspect terms numbered 5 to 10
termMatrix[5:10,5:10]

###
### Build a Graph
###

library(igraph)
# build a graph from the above matrix
g <- graph.adjacency(termMatrix, weighted=T, mode = "undirected")
# remove loops
g <- simplify(g)
# set labels and degrees of vertices
V(g)$label <- V(g)$name
n = dim(termMatrix)[1]
for (i in 1:n)
 {V(g)$degree[i] <- sum(termMatrix[i,])
 }
V(g)

###
### Plot the Graph
###

# set seed to make the layout reproducible
set.seed(3952)
layout1 <- layout.fruchterman.reingold(g)
plot(g, layout=layout1)

plot(g, layout=layout.kamada.kawai)
# tkplot(g, layout=layout.kamada.kawai)

###
### Make it Look Better
###

V(g)$label.cex <- 1.4 * V(g)$degree / max(V(g)$degree)+ .8
V(g)$label.color <- rgb(0, 0, .2, .8)
V(g)$frame.color <- NA
egam <- (log(E(g)$weight)+0.1) / max(log(E(g)$weight)+0.1)
E(g)$color <- rgb(.5, .5, 0, 1)
E(g)$width <- egam*1
# plot the graph in layout1
plot(g, layout=layout1)

sink()
dev.off()

