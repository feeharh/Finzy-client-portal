package com.finzyportal.auth;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.finzyportal.auth.dto.LoginRequest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.cookie;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AdminAuthIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void loginWithValidCredentialsCreatesSession() throws Exception {
        LoginRequest request = new LoginRequest("owner@finzy.com", "change-me");

        mockMvc.perform(post("/admin/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("owner@finzy.com"))
                .andExpect(jsonPath("$.role").value("OWNER"))
                .andExpect(cookie().exists("FINZY_ADMIN_SESSION"));
    }

    @Test
    void meRequiresAuthentication() throws Exception {
        mockMvc.perform(get("/admin/auth/me"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void loginAndMeFlow() throws Exception {
        LoginRequest request = new LoginRequest("owner@finzy.com", "change-me");

        mockMvc.perform(post("/admin/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(cookie().exists("FINZY_ADMIN_SESSION"))
                .andExpect(jsonPath("$.firstName").value("Finzy"))
                .andDo(result -> mockMvc.perform(get("/admin/auth/me")
                                .cookie(result.getResponse().getCookie("FINZY_ADMIN_SESSION")))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.email").value("owner@finzy.com")));
    }

    @Test
    void loginWithInvalidPasswordReturnsUnauthorized() throws Exception {
        LoginRequest request = new LoginRequest("owner@finzy.com", "wrong-password");

        mockMvc.perform(post("/admin/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
    }
}
