package com.example.mediroutine.controller;

import com.example.mediroutine.dto.AddMedicineRequest;
import com.example.mediroutine.dto.MedicineRequest;
import com.example.mediroutine.dto.MedicineResponse;
<<<<<<< Updated upstream
import com.example.mediroutine.dto.UpdateMedicineRequest;
=======
import com.example.mediroutine.entity.FrequencyType;
>>>>>>> Stashed changes
import com.example.mediroutine.entity.Medicine;
import com.example.mediroutine.entity.MedicineSchedule;
import com.example.mediroutine.entity.Period;
import com.example.mediroutine.entity.User;
import com.example.mediroutine.service.MedicineScheduleService;
import com.example.mediroutine.service.MedicineService;
import com.example.mediroutine.service.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;

@CrossOrigin(origins = "*", methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.PATCH, RequestMethod.DELETE, RequestMethod.OPTIONS}, allowedHeaders = "*")
@RestController
@RequestMapping("/api/medicines")
@Transactional
public class MedicineController {

    private final MedicineService medicineService;
    private final MedicineScheduleService medicineScheduleService;
    private final UserService userService;

    public MedicineController(MedicineService medicineService,
                              MedicineScheduleService medicineScheduleService,
                              UserService userService) {
        this.medicineService = medicineService;
        this.medicineScheduleService = medicineScheduleService;
        this.userService = userService;
    }

    @PostMapping("/add")
    public ResponseEntity<MedicineResponse> createMedicine(@RequestBody AddMedicineRequest request) {

        Long userId = request.getMedicine().getUserId();
        return userService.getUserById(userId)
                .map(user -> {

                    Medicine savedMedicine =
                            medicineService.addMedicineWithSchedule(
                                    request,
                                    user
                            );
                    return ResponseEntity
                            .status(HttpStatus.CREATED)
                            .body(toResponse(savedMedicine));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    private MedicineResponse toResponse(Medicine medicine) {

        return new MedicineResponse(
                medicine.getId(),
                medicine.getName(),
                medicine.getDescription(),
                medicine.getUser().getId()
        );
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

    // user for getting list of the medicines
    @GetMapping("/user/{userId}")
    public List<MedicineResponse> getMedicinesByUserId(@PathVariable Long userId) {
        return medicineService.getMedicinesByUserId(userId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    /**
     * Add a medicine and its schedule in a single call (medicines and medicine_schedules tables).
     */
    @PostMapping("/add")
    @SuppressWarnings("unchecked")
    public ResponseEntity<?> addMedicine(@RequestBody Map<String, Object> payload) {
        try {
            Map<String, Object> medMap = (Map<String, Object>) payload.get("medicine");
            Map<String, Object> schedMap = (Map<String, Object>) payload.get("schedule");

            if (medMap == null || schedMap == null) {
                return ResponseEntity.badRequest().body("Both medicine and schedule details are required.");
            }

            Object userIdObj = medMap.get("userId");
            if (userIdObj == null) {
                return ResponseEntity.badRequest().body("User ID is required.");
            }
            Long userId = Long.valueOf(userIdObj.toString());

            Optional<User> userOpt = userService.getUserById(userId);
            if (userOpt.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found with ID: " + userId);
            }
            User user = userOpt.get();

            String medName = (String) medMap.get("name");
            if (medName == null || medName.trim().isEmpty()) {
                return ResponseEntity.badRequest().body("Medicine name is required.");
            }
            medName = medName.trim();
            String description = (String) medMap.get("description");

            // 1. Create and save Medicine in medicines table
            Medicine medicine = new Medicine();
            medicine.setName(medName);
            medicine.setDescription(description);
            medicine.setUser(user);
            Medicine savedMedicine = medicineService.saveMedicine(medicine);

            // 2. Parse Schedule fields and save in medicine_schedules table
            String timeStr = (String) schedMap.get("time");
            LocalTime time = timeStr != null ? parseTime(timeStr) : LocalTime.of(8, 30);

            String periodStr = (String) schedMap.get("period");
            Period period = periodStr != null ? Period.valueOf(periodStr.toUpperCase().trim()) : Period.MORNING;

            String freqStr = (String) schedMap.get("frequencyType");
            FrequencyType freq = freqStr != null ? FrequencyType.valueOf(freqStr.toUpperCase().trim()) : FrequencyType.DAILY;

            String startDateStr = (String) schedMap.get("startDate");
            LocalDate startDate = startDateStr != null ? LocalDate.parse(startDateStr) : LocalDate.now();

            String endDateStr = (String) schedMap.get("endDate");
            LocalDate endDate = (endDateStr != null && !endDateStr.trim().isEmpty()) ? LocalDate.parse(endDateStr) : null;

            Integer intervalDays = schedMap.get("intervalDays") != null
                    ? Integer.valueOf(schedMap.get("intervalDays").toString())
                    : null;
            String daysOfWeek = (String) schedMap.get("daysOfWeek");

            String dosage = (String) schedMap.get("dosage");
            Integer quantity = schedMap.get("quantity") != null
                    ? Integer.valueOf(schedMap.get("quantity").toString())
                    : 1;
            String unit = (String) schedMap.get("unit");

            MedicineSchedule schedule = new MedicineSchedule();
            schedule.setMedicine(savedMedicine);
            schedule.setTime(time);
            schedule.setPeriod(period);
            schedule.setFrequencyType(freq);
            schedule.setIntervalDays(intervalDays);
            schedule.setDaysOfWeek(daysOfWeek);
            schedule.setStartDate(startDate);
            schedule.setEndDate(endDate);
            schedule.setDosage(dosage != null ? dosage : "1");
            schedule.setQuantity(quantity);
            schedule.setUnit(unit != null ? unit : "Tablet");

            MedicineSchedule savedSchedule = medicineScheduleService.saveSchedule(schedule);

            Map<String, Object> responseData = new HashMap<>();
            responseData.put("id", savedMedicine.getId());
            responseData.put("medicineId", savedMedicine.getId());
            responseData.put("scheduleId", savedSchedule.getId());
            responseData.put("userId", userId);
            responseData.put("medicineName", medName);
            responseData.put("name", medName);
            responseData.put("description", description);
            responseData.put("instruction", description);
            responseData.put("dosage", schedule.getDosage());
            responseData.put("quantity", schedule.getQuantity());
            responseData.put("unit", schedule.getUnit());
            responseData.put("time", time.toString());
            responseData.put("period", period.name());
            responseData.put("frequencyType", freq.name());
            responseData.put("startDate", startDate.toString());
            if (endDate != null) responseData.put("endDate", endDate.toString());

            return ResponseEntity.status(HttpStatus.CREATED).body(responseData);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to add medicine schedule: " + e.getMessage());
        }
    }

    /**
     * Helper to extract ID from payload
     */
    private Long extractIdFromPayload(Map<String, Object> payload, String... keys) {
        if (payload == null) return null;
        for (String key : keys) {
            if (payload.containsKey(key) && payload.get(key) != null) {
                try {
                    return Long.valueOf(payload.get(key).toString().trim());
                } catch (Exception ignored) {
                }
            }
        }
        return null;
    }

    /**
     * PATCH /api/medicines/update/{medicineId}
     * PATCH /api/medicines/edit/{medicineId}
     * PATCH /api/medicines/{medicineId}
     * Dedicated PATCH endpoint for edit dialog
     */
    @PatchMapping(value = {"/update/{medicineId}", "/edit/{medicineId}", "/{medicineId}"})
    public ResponseEntity<?> patchMedicine(
            @PathVariable Long medicineId,
            @RequestBody Map<String, Object> updates
    ) {
        System.out.println("[MedicineController] Received PATCH request for medicineId: " + medicineId + ", updates: " + updates);
        return updateMedicineAndSchedule(medicineId, updates);
    }

    /**
     * POST /api/medicines/update/{medicineId}
     * POST /api/medicines/edit/{medicineId}
     * POST /api/medicines/{medicineId}/edit
     * Dedicated POST endpoint for edit dialog
     */
    @PostMapping(value = {"/update/{medicineId}", "/edit/{medicineId}", "/{medicineId}/edit"})
    public ResponseEntity<?> postMedicineUpdate(
            @PathVariable Long medicineId,
            @RequestBody Map<String, Object> updates
    ) {
        System.out.println("[MedicineController] Received POST edit request for medicineId: " + medicineId + ", updates: " + updates);
        return updateMedicineAndSchedule(medicineId, updates);
    }

    /**
     * POST /api/medicines/edit or /api/medicines/update
     * Accepts medicineId inside the JSON request body
     */
    @PostMapping(value = {"/edit", "/update"})
    public ResponseEntity<?> postMedicineEditFromBody(@RequestBody Map<String, Object> updates) {
        Long medicineId = extractIdFromPayload(updates, "medicineId", "id", "scheduleId");
        if (medicineId == null) {
            return ResponseEntity.badRequest().body("Medicine ID is required for edit.");
        }
        System.out.println("[MedicineController] Received POST edit request from body for medicineId: " + medicineId);
        return updateMedicineAndSchedule(medicineId, updates);
    }

    /**
     * PATCH /api/medicines/edit or /api/medicines/update
     * Accepts medicineId inside the JSON request body
     */
    @PatchMapping(value = {"/edit", "/update"})
    public ResponseEntity<?> patchMedicineEditFromBody(@RequestBody Map<String, Object> updates) {
        Long medicineId = extractIdFromPayload(updates, "medicineId", "id", "scheduleId");
        if (medicineId == null) {
            return ResponseEntity.badRequest().body("Medicine ID is required for edit.");
        }
        System.out.println("[MedicineController] Received PATCH edit request from body for medicineId: " + medicineId);
        return updateMedicineAndSchedule(medicineId, updates);
    }

    /**
     * PUT /api/medicines/update/{medicineId}
     * PUT /api/medicines/edit/{medicineId}
     * Backward-compatible PUT endpoint accepting Map
     */
    @PutMapping(value = {"/update/{medicineId}", "/edit/{medicineId}"})
    public ResponseEntity<?> putMedicineUpdate(
            @PathVariable Long medicineId,
            @RequestBody Map<String, Object> updates
    ) {
        System.out.println("[MedicineController] Received PUT edit request for medicineId: " + medicineId);
        return updateMedicineAndSchedule(medicineId, updates);
    }

    /**
     * Core update function for medicine and schedule
     */
    public ResponseEntity<?> updateMedicineAndSchedule(Long medicineId, Map<String, Object> updates) {
        try {
            Optional<Medicine> medOpt = medicineService.getMedicineById(medicineId);
            Medicine medicine;
            MedicineSchedule schedule = null;

            if (medOpt.isPresent()) {
                medicine = medOpt.get();
                List<MedicineSchedule> schedules = medicineScheduleService.getSchedulesByMedicineId(medicineId);
                if (!schedules.isEmpty()) {
                    schedule = schedules.get(0);
                }
            } else {
                // If not found by medicineId, check if medicineId is actually a scheduleId
                Optional<MedicineSchedule> schedOpt = medicineScheduleService.getScheduleById(medicineId);
                if (schedOpt.isPresent()) {
                    schedule = schedOpt.get();
                    medicine = schedule.getMedicine();
                } else {
                    return ResponseEntity.status(HttpStatus.NOT_FOUND)
                            .body("Medicine not found with ID: " + medicineId);
                }
            }

            // 1. Update Medicine fields (table: medicines)
            String newName = updates.containsKey("name") && updates.get("name") != null
                    ? updates.get("name").toString().trim()
                    : (updates.containsKey("medicineName") && updates.get("medicineName") != null
                            ? updates.get("medicineName").toString().trim()
                            : null);

            String newDescription = updates.containsKey("description") && updates.get("description") != null
                    ? updates.get("description").toString().trim()
                    : (updates.containsKey("instructions") && updates.get("instructions") != null
                            ? updates.get("instructions").toString().trim()
                            : (updates.containsKey("instruction") && updates.get("instruction") != null
                                    ? updates.get("instruction").toString().trim()
                                    : null));

            if (medicine != null) {
                if (newName != null && !newName.isEmpty()) {
                    medicine.setName(newName);
                }
                if (newDescription != null) {
                    medicine.setDescription(newDescription);
                }
                medicine = medicineService.saveMedicine(medicine);
            }

            // 2. Update Schedule fields (table: medicine_schedules)
            if (schedule == null && medicine != null) {
                schedule = new MedicineSchedule();
                schedule.setMedicine(medicine);
                schedule.setTime(LocalTime.of(8, 30));
                schedule.setPeriod(Period.MORNING);
                schedule.setFrequencyType(FrequencyType.DAILY);
                schedule.setStartDate(LocalDate.now());
            }

            if (schedule != null) {
                if (updates.containsKey("dosage") && updates.get("dosage") != null) {
                    schedule.setDosage(updates.get("dosage").toString().trim());
                }
                if (updates.containsKey("quantity") && updates.get("quantity") != null) {
                    schedule.setQuantity(Integer.valueOf(updates.get("quantity").toString().trim()));
                }
                if (updates.containsKey("unit") && updates.get("unit") != null) {
                    schedule.setUnit(updates.get("unit").toString().trim());
                }
                if (updates.containsKey("time") && updates.get("time") != null) {
                    schedule.setTime(parseTime(updates.get("time")));
                }
                if (updates.containsKey("period") && updates.get("period") != null) {
                    schedule.setPeriod(Period.valueOf(updates.get("period").toString().toUpperCase().trim()));
                }
                if (updates.containsKey("frequencyType") && updates.get("frequencyType") != null) {
                    schedule.setFrequencyType(FrequencyType.valueOf(updates.get("frequencyType").toString().toUpperCase().trim()));
                }
                if (updates.containsKey("intervalDays")) {
                    Object val = updates.get("intervalDays");
                    schedule.setIntervalDays(val != null && !val.toString().trim().isEmpty() ? Integer.valueOf(val.toString().trim()) : null);
                }
                if (updates.containsKey("daysOfWeek")) {
                    Object val = updates.get("daysOfWeek");
                    schedule.setDaysOfWeek(val != null ? val.toString().trim() : null);
                }
                if (updates.containsKey("startDate") && updates.get("startDate") != null && !updates.get("startDate").toString().trim().isEmpty()) {
                    schedule.setStartDate(LocalDate.parse(updates.get("startDate").toString().trim()));
                }
                if (updates.containsKey("endDate")) {
                    Object val = updates.get("endDate");
                    schedule.setEndDate(val != null && !val.toString().trim().isEmpty() ? LocalDate.parse(val.toString().trim()) : null);
                }
                schedule = medicineScheduleService.saveSchedule(schedule);
            }

            Map<String, Object> responseData = new HashMap<>();
            responseData.put("id", medicine != null ? medicine.getId() : medicineId);
            responseData.put("medicineId", medicine != null ? medicine.getId() : medicineId);
            if (schedule != null) {
                responseData.put("scheduleId", schedule.getId());
                responseData.put("dosage", schedule.getDosage());
                responseData.put("quantity", schedule.getQuantity());
                responseData.put("unit", schedule.getUnit());
                responseData.put("time", schedule.getTime().toString());
                responseData.put("period", schedule.getPeriod().name());
                responseData.put("frequencyType", schedule.getFrequencyType().name());
                responseData.put("startDate", schedule.getStartDate().toString());
                if (schedule.getEndDate() != null) responseData.put("endDate", schedule.getEndDate().toString());
            }
            if (medicine != null) {
                responseData.put("name", medicine.getName());
                responseData.put("medicineName", medicine.getName());
                responseData.put("description", medicine.getDescription());
                responseData.put("instruction", medicine.getDescription());
            }
            responseData.put("message", "Medicine and schedule updated successfully");

            return ResponseEntity.ok(responseData);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to update medicine: " + e.getMessage());
        }
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

    @PatchMapping("/update/{id}")
    public ResponseEntity<MedicineResponse> updateMedicinePartial(
            @PathVariable Long id,
            @RequestBody UpdateMedicineRequest request
    ) {

        try {

            Medicine updatedMedicine =
                    medicineService.updateMedicinePartial(id, request);

            return ResponseEntity.ok(
                    toResponse(updatedMedicine)
            );

        } catch (RuntimeException e) {

            return ResponseEntity.notFound().build();
        }
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

<<<<<<< Updated upstream



=======
    private LocalTime parseTime(Object timeObj) {
        if (timeObj == null) return LocalTime.of(8, 30);
        String timeStr = timeObj.toString().trim();
        if (timeStr.toUpperCase().contains("AM") || timeStr.toUpperCase().contains("PM")) {
            boolean isPm = timeStr.toUpperCase().contains("PM");
            String cleaned = timeStr.replaceAll("(?i)[AP]M", "").trim();
            String[] parts = cleaned.split(":");
            int hour = Integer.parseInt(parts[0].trim());
            int minute = parts.length > 1 ? Integer.parseInt(parts[1].trim()) : 0;
            if (isPm && hour < 12) hour += 12;
            if (!isPm && hour == 12) hour = 0;
            return LocalTime.of(hour, minute);
        }
        if (timeStr.length() == 5) {
            return LocalTime.parse(timeStr + ":00");
        }
        return LocalTime.parse(timeStr);
    }

    private MedicineResponse toResponse(Medicine medicine) {
        MedicineResponse response = new MedicineResponse(
                medicine.getId(),
                medicine.getName(),
                medicine.getDescription(),
                medicine.getUser() != null ? medicine.getUser().getId() : null
        );

        if (medicine.getSchedules() != null && !medicine.getSchedules().isEmpty()) {
            MedicineSchedule schedule = medicine.getSchedules().get(0);
            response.setScheduleId(schedule.getId());
            response.setDosage(schedule.getDosage());
            response.setQuantity(schedule.getQuantity());
            response.setUnit(schedule.getUnit());
            response.setTime(schedule.getTime() != null ? schedule.getTime().toString() : null);
            response.setPeriod(schedule.getPeriod() != null ? schedule.getPeriod().name() : null);
            response.setFrequencyType(schedule.getFrequencyType() != null ? schedule.getFrequencyType().name() : null);
            response.setIntervalDays(schedule.getIntervalDays());
            response.setDaysOfWeek(schedule.getDaysOfWeek());
            response.setStartDate(schedule.getStartDate() != null ? schedule.getStartDate().toString() : null);
            response.setEndDate(schedule.getEndDate() != null ? schedule.getEndDate().toString() : null);
        }

        return response;
    }
>>>>>>> Stashed changes
}
