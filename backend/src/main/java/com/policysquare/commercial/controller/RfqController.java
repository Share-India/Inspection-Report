package com.policysquare.commercial.controller;

import com.policysquare.commercial.model.Rfq;
import com.policysquare.commercial.service.RfqService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/rfq")
@CrossOrigin(originPatterns = "*")
@RequiredArgsConstructor
public class RfqController {

    private final RfqService service;

    @PostMapping
    public ResponseEntity<?> submitRfq(@RequestBody Rfq rfq) {
        try {
            return ResponseEntity.ok(service.submitRfq(rfq));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Error submitting RFQ: " + e.getMessage());
        }
    }

    @GetMapping
    public ResponseEntity<List<Rfq>> getAllRfqs() {
        return ResponseEntity.ok(service.getAllRfqs());
    }

    @GetMapping("/user/{mobileNumber}")
    public ResponseEntity<List<Rfq>> getUserRfqs(@PathVariable String mobileNumber) {
        return ResponseEntity.ok(service.getUserRfqs(mobileNumber));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Rfq> getRfqById(@PathVariable String id) {
        return ResponseEntity.ok(service.getRfqById(id));
    }

    @PutMapping(value = "/{id}/quote", consumes = {"multipart/form-data"})
    public ResponseEntity<?> updateQuote(
            @PathVariable String id,
            @RequestParam("quoteDetails") String quoteDetails,
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "file", required = false) org.springframework.web.multipart.MultipartFile file) {
        try {
            return ResponseEntity.ok(service.updateQuote(id, quoteDetails, status, file));
        } catch (Exception e) {
             e.printStackTrace();
             return ResponseEntity.internalServerError().body("Error updating quote: " + e.getMessage());
        }
    }
}
