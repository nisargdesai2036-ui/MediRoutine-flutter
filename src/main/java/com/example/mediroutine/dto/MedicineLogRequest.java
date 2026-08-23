package com.example.mediroutine.dto;

import com.example.mediroutine.entity.LogStatus;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public class MedicineLogRequest {

    private Long scheduleId;
    private LocalDate scheduledDate;
    private LocalTime scheduledTime;
    private LocalDateTime actionTime;
    private LogStatus status;

    public MedicineLogRequest() {
    }

    public MedicineLogRequest(Long scheduleId, LocalDate scheduledDate, LocalTime scheduledTime,
                              LocalDateTime actionTime, LogStatus status) {
        this.scheduleId = scheduleId;
        this.scheduledDate = scheduledDate;
        this.scheduledTime = scheduledTime;
        this.actionTime = actionTime;
        this.status = status;
    }

    public Long getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(Long scheduleId) {
        this.scheduleId = scheduleId;
    }

    public LocalDate getScheduledDate() {
        return scheduledDate;
    }

    public void setScheduledDate(LocalDate scheduledDate) {
        this.scheduledDate = scheduledDate;
    }

    public LocalTime getScheduledTime() {
        return scheduledTime;
    }

    public void setScheduledTime(LocalTime scheduledTime) {
        this.scheduledTime = scheduledTime;
    }

    public LocalDateTime getActionTime() {
        return actionTime;
    }

    public void setActionTime(LocalDateTime actionTime) {
        this.actionTime = actionTime;
    }

    public LogStatus getStatus() {
        return status;
    }

    public void setStatus(LogStatus status) {
        this.status = status;
    }
}
