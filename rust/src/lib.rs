pub mod api;
mod frb_generated;

#[no_mangle]
pub extern "C" fn dummy_method_to_enforce_bundling() {}
