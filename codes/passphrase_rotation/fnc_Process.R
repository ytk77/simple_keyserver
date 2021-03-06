library(sodium)
library(doMC)
library(stringi)
library(mailR)

encrypt_password_source <- function(access, value)
{
    fpath = "~/simple_keyserver/data/password_src/"
    dir.create(fpath, showWarnings = FALSE)
    
    magic <- system('cat ~/simple_keyserver/data/magic', intern = TRUE)
    key = hash(charToRaw(magic))
    msg = serialize(value, NULL)
    cipher <- data_encrypt(msg, key)
    
    fname = paste0(fpath, access, '.rds')
    saveRDS(cipher, fname)
}

## used when we want to change passphrase for all users
rotate_passphrase <- function()
{
    fpath1 = "~/simple_keyserver/data/passwords/"
    
    access_tbl <- read.csv("~/simple_keyserver/data/access_table.csv", 
                           strip.white = TRUE, stringsAsFactors = FALSE)
    ## convert USERS into row-wise table
    access_tbl2 <- foreach(ii=1:nrow(access_tbl), .combine=rbind) %do% {
        r1 <- access_tbl[ii, ]
        users = strsplit(r1$USERS, "/")[[1]]
        res <- data.frame(ACCESS=r1$ACCESS, USER=users, stringsAsFactors = FALSE)
    }
    
    users <- unique(access_tbl2$USER)
    for (uu in users) {
        ## generate a new passphrase
        passphrase = paste0( stri_rand_strings(1, 4, pattern="[a-z]"),
                     stri_rand_strings(1, 4, pattern="[0-9]") )
        ## clean up old data
        unlink(file.path(fpath1,uu), recursive = TRUE)
        ## save this new passphrase
        dir.create(file.path(fpath1,uu), showWarnings = FALSE)
        cmd = paste0('echo ', passphrase, ' > ', fpath1, uu, '/passphrase')
        system(cmd)
        ## encrypt passwords with new passphrase
        accesses = subset(access_tbl2, USER==uu)
        for (ii in 1:nrow(accesses)) {
            access = accesses[ii, ]
            encrypt_user_password(access, passphrase)
        }
        ## email send out new passphrase
        email_new_passphrase(uu, passphrase)
    }
    
}


encrypt_user_password <- function(access, passphrase)
{
    fpath = "~/simple_keyserver/data/password_src/"
    fpath2 = "~/simple_keyserver/data/passwords/"
    
    ## load password from source
    magic <- system('cat ~/simple_keyserver/data/magic', intern = TRUE)
    key = hash(charToRaw(magic))
    cipher = try( readRDS(paste0(fpath, access$ACCESS, '.rds')) )
    if (class(cipher)!='try-error') {
        ## decrypt
        orig <- data_decrypt(cipher, key)
            # value = unserialize(orig)
        ## encrypt with user's passphrase
        key = hash(charToRaw(passphrase))
            # msg = serialize(value, NULL)
        cipher2 <- data_encrypt(orig, key)
        fn = paste0(fpath2, access$USER, '/', access$ACCESS, '.rds')
        saveRDS(cipher2, fn)
    } else {
        print(cipher)
    }
}


## used when updating encrypted passwords (using old passphrases)
update_user_passwords <- function()
{
    fpath1 = "~/simple_keyserver/data/passwords/"
    
    access_tbl <- read.csv("~/simple_keyserver/data/access_table.csv", 
                           strip.white = TRUE, stringsAsFactors = FALSE)
    ## convert USERS into row-wise table
    access_tbl2 <- foreach(ii=1:nrow(access_tbl), .combine=rbind) %do% {
        r1 <- access_tbl[ii, ]
        users = strsplit(r1$USERS, "/")[[1]]
        res <- data.frame(ACCESS=r1$ACCESS, USER=users, stringsAsFactors = FALSE)
    }
    
    users <- unique(access_tbl2$USER)
    for (uu in users) {
        ## fetch old passphrase
        cmd = paste0("cat ", fpath1, uu, "/passphrase")
        passphrase = system(cmd, intern = TRUE)
        ## clean up old data
        cmd = paste0("rm ", fpath1, uu, "/*.rds")
        system(cmd)
        ## encrypt passwords with new passphrase
        accesses = subset(access_tbl2, USER==uu)
        for (ii in 1:nrow(accesses)) {
            access = accesses[ii, ]
            encrypt_user_password(access, passphrase)
        }
    }
    
}


email_new_passphrase <- function(uu, passphrase)
{
    sender <- "myemail@gmail.com" # Replace with a valid address
    
    ## read email list
    email_list <- read.csv("~/simple_keyserver/data/email_list.csv",
                           strip.white = TRUE, stringsAsFactors = FALSE)
    
    addr <- subset(email_list, USER==uu)
    if (nrow(addr)>0) {
        send.mail(from = sender,
                  to = addr$EMAIL,
                  subject="New Passphrase for Keyserver",
                  body = passphrase,
                  smtp = list(host.name = "smtp.gmail.com", port = 465,
                              user.name="myemail@gmail.com",
                              passwd="mypassword", ssl=TRUE),
                  authenticate = TRUE, send = TRUE)
    } else {
        cat(uu, "is not in the email list\n")
    }
}
