source("fnc_Process.R")

encrypt_password_source("srv1_user1", "192.168.1.10___user1___password1")
encrypt_password_source("srv2_user2", "192.168.1.11___user2___password2")
encrypt_password_source("srv3_user3", "192.168.1.12___user3___password3")


update_user_passwords()