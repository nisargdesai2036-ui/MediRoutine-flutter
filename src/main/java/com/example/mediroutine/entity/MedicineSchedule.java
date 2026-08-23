package com.example.mediroutine.entity;

import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "medicine_schedules")
public class MedicineSchedule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /*
     * Many schedules can belong to one medicine.
     *
     * Example:
     * Paracetamol
     *   ├── Morning schedule
     *   └── Night schedule
     */
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "medicine_id", nullable = false)
    private Medicine medicine;

    /*
     * Dosage is optional because not every medicine routine
     * necessarily has a specified dosage.
     */
    private String dosage;


    private Integer quantity;

    private String unit;

    /*
     * Actual time at which medicine should be taken.
     *
     * Example: 08:00
     */
    @Column(nullable = false)
    private LocalTime time;

    /*
     * Mainly used to categorize the schedule in the UI.
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Period period;

    /*
     * Determines how frequently the medicine is taken.
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private FrequencyType frequencyType;

    /*
     * Used only when frequencyType = EVERY_N_DAYS.
     *
     * Example:
     * intervalDays = 2
     * means every 2 days.
     */
    private Integer intervalDays;

    /*
     * Used when frequencyType = SPECIFIC_DAYS.
     *
     * Example:
     * "MON,WED,FRI"
     */
    private String daysOfWeek;

    @Column(nullable = false)
    private LocalDate startDate;

    private LocalDate endDate;
    @OneToMany(
            mappedBy = "schedule",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<MedicineLog> logs = new ArrayList<>();

    public MedicineSchedule() {
    }

    public List<MedicineLog> getLogs() {
        return logs;
    }

    public void setLogs(List<MedicineLog> logs) {
        this.logs = logs;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Medicine getMedicine() {
        return medicine;
    }

    public void setMedicine(Medicine medicine) {
        this.medicine = medicine;
    }

    public String getDosage() {
        return dosage;
    }

    public void setDosage(String dosage) {
        this.dosage = dosage;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public LocalTime getTime() {
        return time;
    }

    public void setTime(LocalTime time) {
        this.time = time;
    }

    public Period getPeriod() {
        return period;
    }

    public void setPeriod(Period period) {
        this.period = period;
    }

    public FrequencyType getFrequencyType() {
        return frequencyType;
    }

    public void setFrequencyType(FrequencyType frequencyType) {
        this.frequencyType = frequencyType;
    }

    public Integer getIntervalDays() {
        return intervalDays;
    }

    public void setIntervalDays(Integer intervalDays) {
        this.intervalDays = intervalDays;
    }

    public String getDaysOfWeek() {
        return daysOfWeek;
    }

    public void setDaysOfWeek(String daysOfWeek) {
        this.daysOfWeek = daysOfWeek;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }
}