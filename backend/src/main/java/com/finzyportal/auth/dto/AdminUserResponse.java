package com.finzyportal.auth.dto;

import com.finzyportal.auth.entity.AdminRole;
import com.finzyportal.auth.entity.AdminUser;

import java.util.UUID;

public record AdminUserResponse(
        UUID id,
        String firstName,
        String lastName,
        String email,
        AdminRole role
) {
    public static AdminUserResponse from(AdminUser user) {
        return new AdminUserResponse(
                user.getId(),
                user.getFirstName(),
                user.getLastName(),
                user.getEmail(),
                user.getRole()
        );
    }
}
