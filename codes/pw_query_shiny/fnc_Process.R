library(doMC)
library(sodium)

query_passwords <- function(user, passphrase)
{
    fpath1 = file.path("~/simple_keyserver/data/passwords/", user)
    f_list = list.files(fpath1, pattern='.rds', full.names = TRUE)
    key = hash(charToRaw(passphrase))
    
    R1 <- foreach(ff=f_list, .combine = rbind) %do% {
        access = gsub("\\.rds", '', tail(strsplit(ff, '/')[[1]], 1))
        cipher <- readRDS(ff)
        orig <- try( data_decrypt(cipher, key) )
        if (class(orig)=="try-error") {
            res <- data.frame(ACCESS = '-', INFO = "worng passphrase")
        } else {
            value = unserialize(orig)
            res <- data.frame(ACCESS = access, INFO = value)
        }
        return(res)
    }
    
    return(R1)
}
