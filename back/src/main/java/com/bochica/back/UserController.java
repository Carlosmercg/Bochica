package com.bochica.back;

import com.google.firebase.auth.FirebaseToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class UserController {

    @GetMapping("/api/user/me")
    public Map<String, Object> me(Authentication auth) {
        String uid = (String) auth.getPrincipal();
        FirebaseToken token = (FirebaseToken) auth.getDetails();

        return Map.of(
                "uid", uid,
                "email", token.getEmail(),
                "name", token.getName(),
                "claims", token.getClaims()
        );
    }
}
