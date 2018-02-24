## USAGE
## R >
##     API <- plumber::plumb("api_server_func.R")
##     API$run(host="10.10.7.233", port=9000)

library(plumber)
library(sodium)
library(broman)

source("../passphrase_rotation/fnc_Process.R")

#' @get /newpassword
function(access, value, token) {
    priv_token = "52d7ef4ee01e2c2c75bff572f957cd4f12d6225eee07ea2f01d02b"
    if (token==priv_token) {
        print(access);
        ## decrypt ciphertext @ value
        pri_key = readRDS("data/pri_key.rds")
        v2 = raw( nchar(value)/2 )
        for (ii in 1:length(v2) ) {
            jj = 2*(ii-1)
            v2[ii] = as.raw( hex2bin( substr(value, jj+1, jj+2)) )
        }
        out <- simple_decrypt(v2, pri_key)
        info = rawToChar( unserialize(out) )
        ## save access info.
        encrypt_password_source(access, info)
        update_user_passwords()
    } else {
        return("token error.")
    }
    
    return("done")
}


