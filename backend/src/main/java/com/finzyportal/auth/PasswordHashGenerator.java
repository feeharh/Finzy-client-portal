package com.finzyportal.auth;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/** Run manually to generate password hashes for Flyway seed migrations. */
public class PasswordHashGenerator {

    public static void main(String[] args) {
        String password = args.length > 0 ? args[0] : "change-me";
        System.out.println(new BCryptPasswordEncoder().encode(password));
    }
}
