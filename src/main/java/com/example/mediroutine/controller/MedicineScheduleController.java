package com.example.mediroutine.controller;

import com.example.mediroutine.dto.MedicineScheduleRequest;
import com.example.mediroutine.dto.MedicineScheduleResponse;
<<<<<<< Updated upstream
import com.example.mediroutine.dto.UpdateMedicineScheduleRequest;
=======
import com.example.mediroutine.entity.FrequencyType;
>>>>>>> Stashed changes
import com.example.mediroutine.entity.Medicine;
import com.example.mediroutine.entity.MedicineSchedule;
import com.example.mediroutine.entity.Period;
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
import java.util.stream.Collectors;

@CrossOrigin(origins = "*", methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.PATCH, RequestMethod.DELETE, RequestMethod.OPTIONS}, allowedHeaders = "*")
@RestController
@RequestMapping("/api/schedules")
@Transactional
public class MedicineScheduleController {

    private final MedicineScheduleService medicineScheduleService;
    private final MedicineService medicineService;
    private final UserService userService;

    public MedicineScheduleController(MedicineScheduleService medicineScheduleService,
                                      MedicineService medicineService,
                                      UserService userService) {
        this.medicineScheduleService = medicineScheduleService;
        this.medicineService = medicineService;
        this.userService = userService;
    }

    @PostMapping
    public ResponseEntity<MedicineScheduleResponse> createSchedule(@RequestBody MedicineScheduleRequest request) {
        return medicineService.getMedicineById(request.getMedicineId())
                .map(medicine -> {
                    MedicineSchedule schedule = new MedicineSchedule();
                    schedule.setMedicine(medicine);
                    setScheduleFields(schedule, request);

                    MedicineSchedule savedSchedule = medicineScheduleService.saveSchedule(schedule);
                    return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(savedSchedule));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}")
    public ResponseEntity<MedicineScheduleResponse> getScheduleById(@PathVariable Long id) {
        return medicineScheduleService.getScheduleById(id)
                .map(schedule -> ResponseEntity.ok(toResponse(schedule)))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/user/{userId}")
    public List<MedicineScheduleResponse> getSchedulesByUserId(
            @PathVariable Long userId
    ) {

        return medicineScheduleService
                .getSchedulesByUserId(userId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @GetMapping("/medicine/{medicineId}")
    public List<MedicineScheduleResponse> getSchedulesByMedicineId(@PathVariable Long medicineId) {
        return medicineScheduleService.getSchedulesByMedicineId(medicineId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @GetMapping("/user/{userId}")
    public List<MedicineScheduleResponse> getSchedulesByUserId(@PathVariable Long userId) {
        List<MedicineSchedule> schedules = new ArrayList<>(medicineScheduleService.getSchedulesByUserId(userId));

        // Ensure all user medicines are present; if any medicine lacks a schedule, create a default one
        List<Medicine> userMedicines = medicineService.getMedicinesByUserId(userId);
        Set<Long> scheduledMedIds = schedules.stream()
                .filter(s -> s.getMedicine() != null)
                .map(s -> s.getMedicine().getId())
                .collect(Collectors.toSet());

        for (Medicine med : userMedicines) {
            if (!scheduledMedIds.contains(med.getId())) {
                MedicineSchedule defaultSched = new MedicineSchedule();
                defaultSched.setMedicine(med);
                defaultSched.setTime(LocalTime.of(8, 30));
                defaultSched.setPeriod(Period.MORNING);
                defaultSched.setFrequencyType(FrequencyType.DAILY);
                defaultSched.setStartDate(LocalDate.now());
                defaultSched.setDosage("1 Tablet");
                defaultSched.setQuantity(1);
                defaultSched.setUnit("Tablet");
                MedicineSchedule saved = medicineScheduleService.saveSchedule(defaultSched);
                schedules.add(saved);
                scheduledMedIds.add(med.getId());
            }
        }

        return schedules.stream()
                .map(this::toResponse)
                .toList();
    }

    @GetMapping
    public List<MedicineScheduleResponse> getAllSchedules() {
        return medicineScheduleService.getAllSchedules()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @PutMapping("/{id}")
    public ResponseEntity<MedicineScheduleResponse> updateSchedule(
            @PathVariable Long id,
            @RequestBody MedicineScheduleRequest request
    ) {
        return medicineScheduleService.getScheduleById(id)
                .map(existingSchedule -> {
                    if (request.getMedicineId() != null &&
                            (existingSchedule.getMedicine() == null || !existingSchedule.getMedicine().getId().equals(request.getMedicineId()))) {
                        Medicine medicine = medicineService.getMedicineById(request.getMedicineId()).orElse(null);
                        if (medicine == null) {
                            return ResponseEntity.notFound().<MedicineScheduleResponse>build();
                        }
                        existingSchedule.setMedicine(medicine);
                    }

                    setScheduleFields(existingSchedule, request);
                    MedicineSchedule savedSchedule = medicineScheduleService.saveSchedule(existingSchedule);
                    return ResponseEntity.ok(toResponse(savedSchedule));
                })
                .orElse(ResponseEntity.notFound().build());
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
     * PATCH /api/schedules/update/{scheduleId}
     * PATCH /api/schedules/edit/{scheduleId}
     * PATCH /api/schedules/{scheduleId}
     * Dedicated PATCH endpoint for edit dialog
     */
    @PatchMapping(value = {"/update/{scheduleId}", "/edit/{scheduleId}", "/{scheduleId}"})
    public ResponseEntity<?> patchSchedule(
            @PathVariable Long scheduleId,
            @RequestBody Map<String, Object> updates
    ) {
        System.out.println("[MedicineScheduleController] Received PATCH request for scheduleId: " + scheduleId + ", updates: " + updates);
        return updateScheduleAndMedicine(scheduleId, updates);
    }

    /**
     * POST /api/schedules/update/{scheduleId}
     * POST /api/schedules/edit/{scheduleId}
     * POST /api/schedules/{scheduleId}/edit
     * Dedicated POST endpoint for edit dialog
     */
    @PostMapping(value = {"/update/{scheduleId}", "/edit/{scheduleId}", "/{scheduleId}/edit"})
    public ResponseEntity<?> postScheduleUpdate(
            @PathVariable Long scheduleId,
            @RequestBody Map<String, Object> updates
    ) {
        System.out.println("[MedicineScheduleController] Received POST edit request for scheduleId: " + scheduleId + ", updates: " + updates);
        return updateScheduleAndMedicine(scheduleId, updates);
    }

    /**
     * POST /api/schedules/edit or /api/schedules/update
     * Accepts scheduleId inside the JSON request body
     */
    @PostMapping(value = {"/edit", "/update"})
    public ResponseEntity<?> postScheduleEditFromBody(@RequestBody Map<String, Object> updates) {
        Long scheduleId = extractIdFromPayload(updates, "scheduleId", "id", "medicineId");
        if (scheduleId == null) {
            return ResponseEntity.badRequest().body("Schedule ID is required for edit.");
        }
        System.out.println("[MedicineScheduleController] Received POST edit request from body for scheduleId: " + scheduleId);
        return updateScheduleAndMedicine(scheduleId, updates);
    }

    /**
     * PATCH /api/schedules/edit or /api/schedules/update
     * Accepts scheduleId inside the JSON request body
     */
    @PatchMapping(value = {"/edit", "/update"})
    public ResponseEntity<?> patchScheduleEditFromBody(@RequestBody Map<String, Object> updates) {
        Long scheduleId = extractIdFromPayload(updates, "scheduleId", "id", "medicineId");
        if (scheduleId == null) {
            return ResponseEntity.badRequest().body("Schedule ID is required for edit.");
        }
        System.out.println("[MedicineScheduleController] Received PATCH edit request from body for scheduleId: " + scheduleId);
        return updateScheduleAndMedicine(scheduleId, updates);
    }

    /**
     * PUT /api/schedules/update/{scheduleId}
     * PUT /api/schedules/edit/{scheduleId}
     * Backward-compatible PUT endpoint accepting Map
     */
    @PutMapping(value = {"/update/{scheduleId}", "/edit/{scheduleId}"})
    public ResponseEntity<?> putScheduleUpdate(
            @PathVariable Long scheduleId,
            @RequestBody Map<String, Object> updates
    ) {
        System.out.println("[MedicineScheduleController] Received PUT edit request for scheduleId: " + scheduleId);
        return updateScheduleAndMedicine(scheduleId, updates);
    }

    /**
     * Core update function for schedule and associated medicine
     */
    public ResponseEntity<?> updateScheduleAndMedicine(Long scheduleId, Map<String, Object> updates) {
        try {
            Optional<MedicineSchedule> scheduleOpt = medicineScheduleService.getScheduleById(scheduleId);
            MedicineSchedule schedule;

            if (scheduleOpt.isPresent()) {
                schedule = scheduleOpt.get();
            } else {
                // If not found by scheduleId, check if scheduleId is actually a medicineId
                Optional<Medicine> medOpt = medicineService.getMedicineById(scheduleId);
                if (medOpt.isPresent()) {
                    Medicine med = medOpt.get();
                    List<MedicineSchedule> medSchedules = medicineScheduleService.getSchedulesByMedicineId(med.getId());
                    if (!medSchedules.isEmpty()) {
                        schedule = medSchedules.get(0);
                    } else {
                        schedule = new MedicineSchedule();
                        schedule.setMedicine(med);
                        schedule.setTime(LocalTime.of(8, 30));
                        schedule.setPeriod(Period.MORNING);
                        schedule.setFrequencyType(FrequencyType.DAILY);
                        schedule.setStartDate(LocalDate.now());
                    }
                } else {
                    return ResponseEntity.status(HttpStatus.NOT_FOUND)
                            .body("Schedule not found with ID: " + scheduleId);
                }
            }

            // 1. Update Schedule fields
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

            // 2. Update linked Medicine (table: medicines)
            Medicine medicine = schedule.getMedicine();
            if (medicine != null) {
                boolean medChanged = false;
                String name = updates.containsKey("name") && updates.get("name") != null
                        ? updates.get("name").toString().trim()
                        : (updates.containsKey("medicineName") && updates.get("medicineName") != null
                                ? updates.get("medicineName").toString().trim()
                                : null);
                if (name != null && !name.isEmpty()) {
                    medicine.setName(name);
                    medChanged = true;
                }

                String desc = updates.containsKey("description") && updates.get("description") != null
                        ? updates.get("description").toString().trim()
                        : (updates.containsKey("instructions") && updates.get("instructions") != null
                                ? updates.get("instructions").toString().trim()
                                : (updates.containsKey("instruction") && updates.get("instruction") != null
                                        ? updates.get("instruction").toString().trim()
                                        : null));
                if (desc != null) {
                    medicine.setDescription(desc);
                    medChanged = true;
                }

                if (medChanged) {
                    medicineService.saveMedicine(medicine);
                }
            }

            MedicineSchedule savedSchedule = medicineScheduleService.saveSchedule(schedule);
            return ResponseEntity.ok(toResponse(savedSchedule));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to update schedule: " + e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSchedule(@PathVariable Long id) {
        if (medicineScheduleService.getScheduleById(id).isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        medicineScheduleService.deleteMedicineScheduleById(id);
        return ResponseEntity.noContent().build();
    }

    private void setScheduleFields(MedicineSchedule schedule, MedicineScheduleRequest request) {
        schedule.setDosage(request.getDosage());
        schedule.setQuantity(request.getQuantity());
        schedule.setUnit(request.getUnit());
        schedule.setTime(request.getTime());
        schedule.setPeriod(request.getPeriod());
        schedule.setFrequencyType(request.getFrequencyType());
        schedule.setIntervalDays(request.getIntervalDays());
        schedule.setDaysOfWeek(request.getDaysOfWeek());
        schedule.setStartDate(request.getStartDate());
        schedule.setEndDate(request.getEndDate());
    }

<<<<<<< Updated upstream
    @PatchMapping("/update/{id}")
    public ResponseEntity<MedicineScheduleResponse> updateSchedulePartial(
            @PathVariable Long id,
            @RequestBody UpdateMedicineScheduleRequest request
    ) {

        try {

            MedicineSchedule existingSchedule =
                    medicineScheduleService
                            .getScheduleById(id)
                            .orElseThrow(() ->
                                    new RuntimeException("Schedule not found")
                            );

            Medicine medicine = existingSchedule.getMedicine();

            /*
             * If medicineId was supplied in the PATCH body,
             * find that medicine.
             */
            if (request.getMedicineId() != null) {

                medicine = medicineService
                        .getMedicineById(request.getMedicineId())
                        .orElseThrow(() ->
                                new RuntimeException("Medicine not found")
                        );
            }

            MedicineSchedule updatedSchedule =
                    medicineScheduleService.updateSchedulePartial(
                            id,
                            request,
                            medicine
                    );

            return ResponseEntity.ok(
                    toResponse(updatedSchedule)
            );

        } catch (RuntimeException e) {

            return ResponseEntity.notFound().build();
        }
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
>>>>>>> Stashed changes
    }

    private MedicineScheduleResponse toResponse(MedicineSchedule schedule) {
        Long medId = schedule.getMedicine() != null ? schedule.getMedicine().getId() : null;
        Long userId = schedule.getMedicine() != null && schedule.getMedicine().getUser() != null
                ? schedule.getMedicine().getUser().getId()
                : null;
        String medName = schedule.getMedicine() != null ? schedule.getMedicine().getName() : "Medicine";
        String medDesc = schedule.getMedicine() != null ? schedule.getMedicine().getDescription() : null;

        return new MedicineScheduleResponse(
                schedule.getId(),
                medId,
                userId,
                medName,
                medDesc,
                schedule.getDosage(),
                schedule.getQuantity(),
                schedule.getUnit(),
                schedule.getTime(),
                schedule.getPeriod(),
                schedule.getFrequencyType(),
                schedule.getIntervalDays(),
                schedule.getDaysOfWeek(),
                schedule.getStartDate(),
                schedule.getEndDate()
        );
    }
}
