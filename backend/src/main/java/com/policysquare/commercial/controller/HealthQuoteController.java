package com.policysquare.commercial.controller;

import com.policysquare.commercial.dto.HealthQuoteRequest;
import com.policysquare.commercial.service.HealthQuoteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.jdbc.core.JdbcTemplate;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Map;

@RestController
@RequestMapping("/api/health/quotes")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class HealthQuoteController {


    @Autowired
    private HealthQuoteService quoteService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @PostMapping("/seed")
    public ResponseEntity<?> seedDatabase() {
        try {
            String sql = new String(Files.readAllBytes(Paths.get("health_data.sql")));
            String[] statements = sql.split(";");
            for (String statement : statements) {
                if (!statement.trim().isEmpty()) {
                    jdbcTemplate.execute(statement);
                }
            }
            return ResponseEntity.ok("Database seeded successfully.");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error seeding database: " + e.getMessage());
        }
    }

    @PostMapping("/calculate")
    public ResponseEntity<?> calculateQuotes(@RequestBody HealthQuoteRequest request) {
        try {
            return ResponseEntity.ok(quoteService.calculateQuotes(request));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", "An error occurred during calculation: " + e.getMessage()));
        }
    }
}
