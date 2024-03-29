# ========================================# 
#         Analyse descriptive du corpus 
# ========================================#

library(quanteda)
library(quanteda.textstats)
library(RSQLite)
library(caret)
library(DBI)

#r�partoire de travail 
setwd("C:\\Users\\In�s\\Cours M2 SISE\\Texte Ming - Ricco R\\Projet -- pole emploie")

# ===================================================#
#   Connection a la base pour r�cup�r� les donn�es 
# ===================================================#

conn <- dbConnect(RSQLite::SQLite(), "corpusOffreData.sqlite")

df <- dbGetQuery(conn,"SELECT * FROM offre")

dbDisconnect(conn)


#=================================================#
#   Mise en place de la matrice document termes 
#=================================================#

# pour que ce soit nettoyer comme nous le voulons 
nettoyage <- function(document){
  #passe en miniature 
  document <- tolower(document)
  #retire les sauts de lignes
  document <- gsub("[\n\r/+]","",document)
  #retire la ponctuation
  #document <- gsub("[\\(,);:.?!'-*]"," ",document)
  #retire les chiffres
  document <- gsub("[0-9]","",document)
  #retire les accents
  document <- gsub("[����]","e",document)
  document <- gsub("[���]","a",document)
  document <- gsub("[��]","i",document)
  document <- gsub("[��]","u",document)
  document <- gsub("[��]","o",document)
}

df$description <- nettoyage(df$description)

#==================================================#
#       Modification du df pour qu'il soit adapt� 
#       au format de quantedas 
#==================================================#

corpus <- corpus(df,text_field='description')

#=====================================#
#       Tokennization des termes
#       Suppression des stopwords
#       Stemining
#=====================================#

mots_vides <- quanteda::stopwords(language = 'fr')
mots_vides <- c(mots_vides,c("data","donnee","donnees","tant","que","hf","fh","en","a","e",""))

#quanteda_options(verbose = TRUE)

corpus.token <- corpus %>%
  tokens(remove_numbers = TRUE,remove_symbols = TRUE,remove_url = TRUE)%>%
  tokens_remove(mots_vides)%>%
  dfm()

print(corpus.token)





#================================================#
#     Analyse descriptives de la matrice 
#     Utilisation du package stats de quanteda
#================================================#

maitrise <- c("python","r","sql","nosql","knime","tableau","powerbi","sas","azure","aws",
              "statistique","mongodb","hadoop","spark","matlab","scala","java","git","github",
              "gitlab","qliksense","cloud","excel","gcp","hive","qlikview","qlik","talend")

#map 
map.dmt <- dfm_match(corpus.token,features = maitrise)
dfMap <- convert(map.dmt,to="data.frame")

dfMap$doc_id <- NULL

liste_maitrise <- apply(dfMap, 1, function(x){
  index <- which(x>0)
  return(names(dfMap)[index])
})

df_maitrise <- c()
for(i in liste_maitrise){
  df_maitrise <- rbind(df_maitrise, toString(i))
}
df_maitrise

#fr�quence des termes 

freq_term <- textstat_frequency(corpus.mindim)
head(freq_term)
tail(freq_term)



library(jsonlite)
library(purrr)
library(data.table)

dt_list <- map(liste_maitrise, as.data.table)
dt <- rbindlist(dt_list, fill = TRUE, idcol = T)

dt


