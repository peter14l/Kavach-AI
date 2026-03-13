use std::time::{SystemTime, UNIX_EPOCH};
use flutter_rust_bridge::frb;
use lopdf::Document;
use ed25519_dalek::{VerifyingKey, Signature, Verifier};
use base64::prelude::*;
use crate::frb_generated::StreamSink;

// --- Architecture: Production-Grade Types ---

#[frb(non_opaque)]
pub struct LicenseStatus {
    pub is_valid: bool,
    pub days_remaining: i32,
    pub last_checked: u64,
}

#[frb(non_opaque)]
pub struct ProcessingUpdate {
    pub step: String,
    pub progress: f32,
}

// --- Task 3: Rust LLM Integration ---

#[frb(init)]
pub fn init_app() {
    // This is where we would initialize the global LLM runtime
}

#[frb(sync)]
pub fn greet(name: String) -> String {
    format!("Hello, {name}! Aegis-Vault is ready.")
}

/// Accept a document path and stream redaction/summarization progress.
/// Uses a Sink to push updates back to Flutter asynchronously.
pub async fn process_document_stream(
    path: String,
    _system_prompt: String,
    sink: StreamSink<ProcessingUpdate>,
) -> anyhow::Result<()> {
    // 1. Ingest document (PDF)
    sink.add(ProcessingUpdate { step: "Ingesting document...".into(), progress: 0.1 }).ok();
    
    // Simulate real I/O with lopdf (fallback to dummy text if not a real PDF path)
    let extracted_text = match Document::load(&path) {
        Ok(doc) => {
            let mut text = String::new();
            let pages = doc.get_pages();
            for (i, _) in pages.iter().enumerate() {
                let page_num = (i + 1) as u32;
                if let Ok(page_text) = doc.extract_text(&[page_num]) {
                    text.push_str(&page_text);
                }
            }
            format!("Extracted {} characters from PDF.", text.len())
        },
        Err(_) => "Simulated document text (failed to load as real PDF).".to_string()
    };
    
    tokio::time::sleep(tokio::time::Duration::from_millis(500)).await;

    // 2. Load LLM (llama-cpp-2 or candle)
    sink.add(ProcessingUpdate { step: "Loading local model (llama.cpp)...".into(), progress: 0.3 }).ok();
    tokio::time::sleep(tokio::time::Duration::from_millis(1000)).await;

    // 3. Inference
    sink.add(ProcessingUpdate { step: "Redacting PII...".into(), progress: 0.6 }).ok();
    // Here we would chunk the `extracted_text` and pass it to the model.
    tokio::time::sleep(tokio::time::Duration::from_millis(1500)).await;

    // 4. Finalize
    sink.add(ProcessingUpdate { step: "Finalizing and generating output PDF...".into(), progress: 0.9 }).ok();
    tokio::time::sleep(tokio::time::Duration::from_millis(500)).await;

    sink.add(ProcessingUpdate { step: "Done".into(), progress: 1.0 }).ok();
    
    Ok(())
}

// --- Task 4: License Validation Logic ---

// Hardcoded public key for the app. The private key remains secure on your server.
// For this example, this is a random valid Ed25519 public key in bytes.
const APP_PUBLIC_KEY: [u8; 32] = [
    215, 90, 152, 1, 130, 177, 10, 183, 213, 75, 254, 211, 201, 100, 7, 58, 
    14, 225, 114, 243, 218, 166, 35, 37, 175, 2, 26, 104, 247, 7, 81, 26
];

/// Securely validate a license key.
/// In production, this uses ed25519 signature verification against a local public key.
/// The `key` format expected here is `base64(message):base64(signature)`
pub fn validate_license(key: String) -> LicenseStatus {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();

    let parts: Vec<&str> = key.split(':').collect();
    if parts.len() != 2 {
        return LicenseStatus { is_valid: false, days_remaining: 0, last_checked: now };
    }

    let message_b64 = parts[0];
    let sig_b64 = parts[1];

    let message = match BASE64_STANDARD.decode(message_b64) {
        Ok(m) => m,
        Err(_) => return LicenseStatus { is_valid: false, days_remaining: 0, last_checked: now },
    };

    let sig_bytes = match BASE64_STANDARD.decode(sig_b64) {
        Ok(s) => s,
        Err(_) => return LicenseStatus { is_valid: false, days_remaining: 0, last_checked: now },
    };

    if sig_bytes.len() != 64 {
        return LicenseStatus { is_valid: false, days_remaining: 0, last_checked: now };
    }

    let signature = match Signature::from_slice(&sig_bytes) {
        Ok(s) => s,
        Err(_) => return LicenseStatus { is_valid: false, days_remaining: 0, last_checked: now },
    };

    let verifying_key = match VerifyingKey::from_bytes(&APP_PUBLIC_KEY) {
        Ok(k) => k,
        Err(_) => return LicenseStatus { is_valid: false, days_remaining: 0, last_checked: now },
    };

    // Verify the cryptographic signature!
    let is_valid = verifying_key.verify(&message, &signature).is_ok();
    
    // As a mock for Demo/Testing without a real key generator, if the key string is "DEMO-KEY" we allow it
    let is_demo_fallback = key == "DEMO-KEY";

    let final_valid = is_valid || is_demo_fallback;

    LicenseStatus {
        is_valid: final_valid,
        days_remaining: if final_valid { 30 } else { 0 },
        last_checked: now,
    }
}

/// Check if the 30-day heartbeat has expired.
/// Flutter UI should lock if this returns true and no internet is available.
pub fn is_heartbeat_expired(last_checked: u64) -> bool {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();
    
    let seconds_in_30_days = 30 * 24 * 60 * 60;
    (now - last_checked) > seconds_in_30_days
}
