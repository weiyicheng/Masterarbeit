# Uebung zur Sentiment Analysis 
# Blog http://stackoverflow.com/questions/22116938/twitter-sentiment-analysis-w-r-using-german-language-set-sentiws 
# dt. pos./neg. Wörter Senti... http://asv.informatik.uni-leipzig.de/download/sentiws.html 
# engl. pos./neg. Words:  http://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html 

setwd("/home/wei/Dropbox/Master Arbeit/reviewMA/Sentiment_Analyse") 
#pdf("adidas1_vergleich.pdf")
# setwd("F:/FP_Data_Mining/R")
sink("./Vergleich/adidas1_vergleich.txt", append=TRUE)


PandN_words <-readLines("SentiWS.txt", encoding = "UTF-8")
PandN_words <-unlist(strsplit(PandN_words, ","))
PandN_words <- tolower(PandN_words)
#PandN_number=dim(PandN_words)[1]
require(plyr)
require(stringr)
library(tm)


score.sentiment = function(sentences, PandN_words, .progress='none')
         { 
          require(plyr)
          require(stringr)
           scores = laply(sentences, function(sentence, PandN_words) 
           {
            docs <- Corpus(VectorSource(sentence))
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
            docs <- tm_map(docs, removeWords, c("schon", "beim")) 

            # Remove punctuations
            docs <- tm_map(docs, removePunctuation)

            # Eliminate extra white spaces
            docs <- tm_map(docs, stripWhitespace)

            # Text stemming
            docs <- tm_map(docs,stemDocument,language="german")
            dataframe<-data.frame(text=unlist(sapply(docs, `[`, "content")), stringsAsFactors=F)
            word.list = str_split(dataframe, '\\s+')
            # sometimes a list() is one level of hierarchy too much
            words = unlist(word.list)
            scoreNumber = 0
            for (word in words) {
                result = match(word, PandN_words)
                if(!is.na(result)){
                       id = as.numeric(result) + 1
                       scoreNumber = scoreNumber + as.numeric(PandN_words[id])
                }
            }
            return(scoreNumber)
           }, 
         PandN_words, .progress=.progress )
         scores.df = data.frame(score=scores, text=sentences)
         return(scores.df)
        }


###Chinesisch
Daten <-read.csv("adidas1_cn.csv", header=TRUE,fileEncoding = "UTF-8", sep = ";")
n=dim(Daten)[1]

###
### Select comments
###
Comments <- matrix(1,n,1)
for (i in 1:n){
  if (Daten[i,3]>=0)  
    Comments[i]=paste(Daten[i,1],Daten[i,2]) 
              }



a <- score.sentiment(Comments, PandN_words)

Scores=a$score
Sterne=Daten[,3]
Scores_cn<-Scores
Sterne_cn<-Sterne

### Deutsch
Daten <-read.csv("adidas1_de.csv", header=TRUE,fileEncoding = "UTF-8", sep = ",")
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


a <- score.sentiment(Comments, PandN_words)
Scores=a$score


Sterne=Daten[,6]

Scores_de<-Scores
Sterne_de<-Sterne
##dataSet<-data.frame(Scores,Sterne)

##wilcox.test(Scores,Sterne,data=dataSet,alternative ="less", distribution ="exact")
var.test(Sterne_cn, Sterne_de)
var.test(Scores_cn, Scores_de)

wilcox.test(Sterne_cn, Sterne_de, alternative = c("two.sided", "less", "greater"))
wilcox.test(Scores_cn, Scores_de, alternative = c("two.sided", "less", "greater"))
y <- c(Sterne_cn, Sterne_de)
group <- as.factor(c(rep(1, length(Sterne_cn)), rep(2, length(Sterne_de))))
library(lawstat)
levene.test(y, group)
y <- c(Scores_cn, Scores_de)
group <- as.factor(c(rep(1, length(Scores_cn)), rep(2, length(Scores_de))))
levene.test(y, group)
cor.test(Sterne_cn, Scores_cn, alternative = "two.sided", method = "pearson", exact = TRUE)
cor.test(Sterne_de, Scores_de, alternative = "two.sided", method = "pearson", exact = TRUE)
cor.test(Sterne_cn, Scores_cn, alternative = "two.sided", method = "spearman")
cor.test(Sterne_de, Scores_de, alternative = "two.sided", method = "spearman")
sink()








