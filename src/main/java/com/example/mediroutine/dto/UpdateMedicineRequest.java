package com.example.mediroutine.dto;

public class UpdateMedicineRequest {

    private String name;
    private String description;

    public UpdateMedicineRequest() {
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}