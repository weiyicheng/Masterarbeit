Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jre7') # for 64-bit version
library(rJava)

# Text mining fuer den IKEA-Katalog
setwd("/Users/alexandra/Documents/Papers/Einzelhandel/R") 
Daten <-read.csv("IKEA_gesamt_internet.csv", header=TRUE, sep = ";")
n=dim(Daten)[1]

Comments <- matrix(1,n,1)
for (i in 1:n){
  if (Daten[i,2]<=5) # alle Zeilen: Sterne <= 5 
    Comments[i]=paste(Daten[i,3],Daten[i,4])
              }
Comments 

library(tm)
myCorpus <- Corpus(VectorSource(Comments))

# Textaufbereitung
myCorpus <- tm_map(myCorpus, tolower)
# remove punctuation
myCorpus <- tm_map(myCorpus, removePunctuation)
# remove numbers
myCorpus <- tm_map(myCorpus, removeNumbers)
# remove stopwords
# keep "r" by removing it from stopwords
myStopwords <- c(stopwords("german"), "available", "via")
# idx <- which(myStopwords == "r")
# myStopwords <- myStopwords[-idx]
myCorpus <- tm_map(myCorpus, removeWords, myStopwords)

# Stemming
library(Snowball)
dictCorpus <- myCorpus
# stem words in a text document with the snowball stemmers,
# which requires packages Snowball, RWeka, rJava, RWekajars
myCorpus <- tm_map(myCorpus, stemDocument, "german")
# inspect the first three ``documents"
inspect(myCorpus[1:3])
# stem completion
myCorpus <- tm_map(myCorpus, stemCompletion, dictionary=dictCorpus)

# Build a Document-Term matrix
myDtm <- TermDocumentMatrix(myCorpus, control = list(minWordLength = 1))
inspect(myDtm)

# Frequent Terms and Associations
findFreqTerms(myDtm, lowfreq=10)
# which words are associated with "langsam"?
findAssocs(myDtm, 'langsam', 0.30)

# Word Cloud
library(wordcloud)
m <- as.matrix(myDtm)
# calculate the frequency of words
v <- sort(rowSums(m), decreasing=TRUE)
myNames <- names(v)
k <- which(names(v)=="miners")
myNames[k] <- "mining"
d <- data.frame(word=myNames, freq=v)
wordcloud(d$word, d$freq, min.freq=5)

write.table(m, "/Users/alexandra/Documents/Papers/Einzelhandel/R/mydata_red.txt", sep="\t")  
             