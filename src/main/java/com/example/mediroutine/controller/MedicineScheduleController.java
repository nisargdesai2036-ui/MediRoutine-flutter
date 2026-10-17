package com.example.mediroutine.controller;

import com.example.mediroutine.dto.MedicineScheduleRequest;
import com.example.mediroutine.dto.MedicineScheduleResponse;
import com.example.mediroutine.dto.UpdateMedicineScheduleRequest;
import com.example.mediroutine.entity.Medicine;
import com.example.mediroutine.entity.MedicineSchedule;
import com.example.mediroutine.service.MedicineScheduleService;
import com.example.mediroutine.service.MedicineService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/schedules")
public class MedicineScheduleController {

    private final MedicineScheduleService medicineScheduleService;
    private final MedicineService medicineService;

    public MedicineScheduleController(MedicineScheduleService medicineScheduleService, MedicineService medicineService) {
        this.medicineScheduleService = medicineScheduleService;
        this.medicineService = medicineService;
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

    @PutMapping("/{id}")
    public ResponseEntity<MedicineScheduleResponse> updateSchedule(
            @PathVariable Long id,
            @RequestBody MedicineScheduleRequest request
    ) {
        return medicineScheduleService.getScheduleById(id)
                .map(existingSchedule -> updateScheduleFromRequest(existingSchedule, request))
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSchedule(@PathVariable Long id) {
        if (medicineScheduleService.getScheduleById(id).isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        medicineScheduleService.deleteMedicineScheduleById(id);
        return ResponseEntity.noContent().build();
    }

    private ResponseEntity<MedicineScheduleResponse> updateScheduleFromRequest(
            MedicineSchedule schedule,
            MedicineScheduleRequest request
    ) {
        if (schedule.getMedicine() == null || !schedule.getMedicine().getId().equals(request.getMedicineId())) {
            Medicine medicine = medicineService.getMedicineById(request.getMedicineId()).orElse(null);
            if (medicine == null) {
                return ResponseEntity.notFound().build();
            }
            schedule.setMedicine(medicine);
        }

        setScheduleFields(schedule, request);
        MedicineSchedule savedSchedule = medicineScheduleService.saveSchedule(schedule);
        return ResponseEntity.ok(toResponse(savedSchedule));
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
    }

    private MedicineScheduleResponse toResponse(MedicineSchedule schedule) {
        return new MedicineScheduleResponse(
                schedule.getId(),
                schedule.getMedicine().getId(),
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
