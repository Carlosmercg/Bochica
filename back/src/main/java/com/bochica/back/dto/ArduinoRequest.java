package com.bochica.back.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public class ArduinoRequest {
    
    @JsonProperty("toggle")
    private Boolean toggle;
    
    @JsonProperty("momentaneo")
    private Boolean momentaneo;
    
    public ArduinoRequest() {
    }
    
    public ArduinoRequest(Boolean toggle, Boolean momentaneo) {
        this.toggle = toggle;
        this.momentaneo = momentaneo;
    }
    
    public Boolean getToggle() {
        return toggle;
    }
    
    public void setToggle(Boolean toggle) {
        this.toggle = toggle;
    }
    
    public Boolean getMomentaneo() {
        return momentaneo;
    }
    
    public void setMomentaneo(Boolean momentaneo) {
        this.momentaneo = momentaneo;
    }
}

