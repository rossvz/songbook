const PlacesAutocomplete = {
  mounted() {
    // Wait for Google Maps API to load
    this.initAutocomplete();
  },

  initAutocomplete() {
    // Check if Google Maps API is loaded
    if (typeof google === "undefined" || !google.maps || !google.maps.places) {
      // Retry after a short delay
      setTimeout(() => this.initAutocomplete(), 100);
      return;
    }

    const input = this.el;
    const autocomplete = new google.maps.places.Autocomplete(input, {
      types: ["establishment"],
      fields: ["name", "geometry.location", "formatted_address"],
    });

    // Listen for place selection
    autocomplete.addListener("place_changed", () => {
      const place = autocomplete.getPlace();

      if (!place.geometry || !place.geometry.location) {
        console.warn("No location data for selected place");
        return;
      }

      // Get latitude and longitude
      const lat = place.geometry.location.lat();
      const lng = place.geometry.location.lng();
      const venueName = place.name || place.formatted_address;

      // Update the input value
      input.value = venueName;

      // Update hidden inputs directly in the DOM so they're included in form submission
      const form = this.el.closest("form");
      if (form) {
        const latInput = form.querySelector('input[name="show[latitude]"]');
        const lngInput = form.querySelector('input[name="show[longitude]"]');
        if (latInput) latInput.value = lat;
        if (lngInput) lngInput.value = lng;
      }

      // Push the location data to the LiveComponent
      // The phx-target attribute tells us which component to target
      const target = form ? form.getAttribute("phx-target") : null;

      if (target) {
        this.pushEventTo(target, "place_selected", {
          venue: venueName,
          latitude: lat,
          longitude: lng,
        });
      }

      // Trigger change event for LiveView form validation
      input.dispatchEvent(new Event("input", { bubbles: true }));
    });

    // Store autocomplete instance for cleanup
    this.autocomplete = autocomplete;
  },

  destroyed() {
    if (this.autocomplete) {
      google.maps.event.clearInstanceListeners(this.autocomplete);
    }
  },
};

export default PlacesAutocomplete;
