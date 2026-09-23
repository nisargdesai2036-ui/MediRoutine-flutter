package com.example.mediroutine.entity;

import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "medicine_logs")
public class MedicineLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /*
     * This log belongs to one particular schedule.
     *
     * Example:
     * Paracetamol - Morning - 8:00 AM
     */
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "schedule_id", nullable = false)
    private MedicineSchedule schedule;

    /*
     * Date for which this dose was scheduled.
     */
    @Column(nullable = false)
    private LocalDate scheduledDate;

    /*
     * Scheduled time for this particular dose.
     */
    @Column(nullable = false)
    private LocalTime scheduledTime;

    /*
     * When the user actually took/skipped the medicine.
     *
     * Can be null if the dose was simply missed.
     */
    private LocalDateTime actionTime;

    @Enumerated(EnumType.STRING)

    @Column(nullable = false)
    private LogStatus status;

    public MedicineLog() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public MedicineSchedule getSchedule() {
        return schedule;
    }

    public void setSchedule(MedicineSchedule schedule) {
        this.schedule = schedule;
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