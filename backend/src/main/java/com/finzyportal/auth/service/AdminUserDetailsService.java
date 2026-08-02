package com.finzyportal.auth.service;

import com.finzyportal.auth.entity.AccountStatus;
import com.finzyportal.auth.entity.AdminUser;
import com.finzyportal.auth.repository.AdminUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminUserDetailsService implements UserDetailsService {

    private final AdminUserRepository adminUserRepository;

    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        AdminUser admin = adminUserRepository.findByEmailIgnoreCase(username)
                .orElseThrow(() -> new UsernameNotFoundException("Invalid credentials"));

        boolean enabled = admin.getAccountStatus() != AccountStatus.DISABLED;
        boolean accountNonLocked = admin.isLoginAllowed();

        return User.builder()
                .username(admin.getEmail())
                .password(admin.getPasswordHash())
                .authorities(new SimpleGrantedAuthority("ROLE_" + admin.getRole().name()))
                .disabled(!enabled)
                .accountLocked(!accountNonLocked)
                .build();
    }
}
