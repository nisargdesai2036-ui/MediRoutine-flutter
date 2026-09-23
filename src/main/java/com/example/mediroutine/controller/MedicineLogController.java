package com.example.mediroutine.controller;

import com.example.mediroutine.dto.MedicineLogRequest;
import com.example.mediroutine.dto.MedicineLogResponse;
import com.example.mediroutine.entity.MedicineLog;
import com.example.mediroutine.entity.MedicineSchedule;
import com.example.mediroutine.service.MedicineLogService;
import com.example.mediroutine.service.MedicineScheduleService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/logs")
public class MedicineLogController {

    private final MedicineLogService medicineLogService;
    private final MedicineScheduleService medicineScheduleService;

    public MedicineLogController(MedicineLogService medicineLogService, MedicineScheduleService medicineScheduleService) {
        this.medicineLogService = medicineLogService;
        this.medicineScheduleService = medicineScheduleService;
    }

    @PostMapping
    public ResponseEntity<MedicineLogResponse> createLog(@RequestBody MedicineLogRequest request) {
        return medicineScheduleService.getScheduleById(request.getScheduleId())
                .map(schedule -> {
                    MedicineLog log = new MedicineLog();
                    log.setSchedule(schedule);
                    setLogFields(log, request);

                    MedicineLog savedLog = medicineLogService.saveLog(log);
                    return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(savedLog));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}")
    public ResponseEntity<MedicineLogResponse> getLogById(@PathVariable Long id) {
        return medicineLogService.getLogById(id)
                .map(log -> ResponseEntity.ok(toResponse(log)))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/schedule/{scheduleId}")
    public List<MedicineLogResponse> getLogsByScheduleId(@PathVariable Long scheduleId) {
        return medicineLogService.getLogsByScheduleId(scheduleId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @PutMapping("/{id}")
    public ResponseEntity<MedicineLogResponse> updateLog(@PathVariable Long id, @RequestBody MedicineLogRequest request) {
        return medicineLogService.getLogById(id)
                .map(existingLog -> updateLogFromRequest(existingLog, request))
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteLog(@PathVariable Long id) {
        if (medicineLogService.getLogById(id).isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        medicineLogService.deleteLogById(id);
        return ResponseEntity.noContent().build();
    }

    private ResponseEntity<MedicineLogResponse> updateLogFromRequest(MedicineLog log, MedicineLogRequest request) {
        if (log.getSchedule() == null || !log.getSchedule().getId().equals(request.getScheduleId())) {
            MedicineSchedule schedule = medicineScheduleService.getScheduleById(request.getScheduleId()).orElse(null);
            if (schedule == null) {
                return ResponseEntity.notFound().build();
            }
            log.setSchedule(schedule);
        }

        setLogFields(log, request);
        MedicineLog savedLog = medicineLogService.saveLog(log);
        return ResponseEntity.ok(toResponse(savedLog));
    }

    private void setLogFields(MedicineLog log, MedicineLogRequest request) {
        log.setScheduledDate(request.getScheduledDate());
        log.setScheduledTime(request.getScheduledTime());
        log.setActionTime(request.getActionTime());
        log.setStatus(request.getStatus());
    }

    private MedicineLogResponse toResponse(MedicineLog log) {
        return new MedicineLogResponse(
                log.getId(),
                log.getSchedule().getId(),
                log.getScheduledDate(),
                log.getScheduledTime(),
                log.getActionTime(),
                log.getStatus()
        );
    }
}
