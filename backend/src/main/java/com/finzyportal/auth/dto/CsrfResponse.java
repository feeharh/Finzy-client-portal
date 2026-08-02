package com.finzyportal.auth.dto;

public record CsrfResponse(
        String token,
        String headerName
) {
}
