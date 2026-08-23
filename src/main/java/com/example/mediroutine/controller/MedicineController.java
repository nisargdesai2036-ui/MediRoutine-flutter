package com.example.mediroutine.controller;

import com.example.mediroutine.dto.MedicineRequest;
import com.example.mediroutine.dto.MedicineResponse;
import com.example.mediroutine.entity.Medicine;
import com.example.mediroutine.entity.User;
import com.example.mediroutine.service.MedicineService;
import com.example.mediroutine.service.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/medicines")
public class MedicineController {

    private final MedicineService medicineService;
    private final UserService userService;

    public MedicineController(MedicineService medicineService, UserService userService) {
        this.medicineService = medicineService;
        this.userService = userService;
    }

    @PostMapping
    public ResponseEntity<MedicineResponse> createMedicine(@RequestBody MedicineRequest request) {
        return userService.getUserById(request.getUserId())
                .map(user -> {
                    Medicine medicine = new Medicine();
                    medicine.setName(request.getName());
                    medicine.setDescription(request.getDescription());
                    medicine.setUser(user);

                    Medicine savedMedicine = medicineService.saveMedicine(medicine);
                    return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(savedMedicine));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping
    public List<MedicineResponse> getAllMedicines() {
        return medicineService.getAllMedicines()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @GetMapping("/{id}")
    public ResponseEntity<MedicineResponse> getMedicineById(@PathVariable Long id) {
        return medicineService.getMedicineById(id)
                .map(medicine -> ResponseEntity.ok(toResponse(medicine)))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/user/{userId}")
    public List<MedicineResponse> getMedicinesByUserId(@PathVariable Long userId) {
        return medicineService.getMedicinesByUserId(userId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @PutMapping("/{id}")
    public ResponseEntity<MedicineResponse> updateMedicine(@PathVariable Long id, @RequestBody MedicineRequest request) {
        return medicineService.getMedicineById(id)
                .map(existingMedicine -> updateMedicineFromRequest(existingMedicine, request))
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMedicine(@PathVariable Long id) {
        if (medicineService.getMedicineById(id).isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        medicineService.deleteMedicineById(id);
        return ResponseEntity.noContent().build();
    }

    private ResponseEntity<MedicineResponse> updateMedicineFromRequest(Medicine medicine, MedicineRequest request) {
        if (medicine.getUser() == null || !medicine.getUser().getId().equals(request.getUserId())) {
            User user = userService.getUserById(request.getUserId()).orElse(null);
            if (user == null) {
                return ResponseEntity.notFound().build();
            }
            medicine.setUser(user);
        }

        medicine.setName(request.getName());
        medicine.setDescription(request.getDescription());

        Medicine savedMedicine = medicineService.saveMedicine(medicine);
        return ResponseEntity.ok(toResponse(savedMedicine));
    }

    private MedicineResponse toResponse(Medicine medicine) {
        return new MedicineResponse(
                medicine.getId(),
                medicine.getName(),
                medicine.getDescription(),
                medicine.getUser().getId()
        );
    }
}
