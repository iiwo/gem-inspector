## 1. Overview

**Gem Name:** gem‑inspector

**Purpose:**  
Develop a Ruby gem that:
- Reads and parses a Gemfile.lock file to extract dependency names and their locked versions.
- For each dependency, queries the RubyGems.org API to:
  - Retrieve available version metadata,
  - Extract the release (built_at) date for the locked version (if available),
  - Determine the latest stable version and its release date.
- Compares the locked version with the latest available version to mark the gem as “outdated” if the locked version is older.
- Applies a configurable maintenance threshold (e.g., 24 months) against the latest release date to decide if the gem is “actively maintained.”
- Exports the results as a CSV report that includes:
  - Gem Name,
  - Locked Version,
  - Locked Version Release Date,
  - Latest Version,
  - Latest Release Date,
  - Actively Maintained (yes/no),
  - Outdated (yes/no),
  - (Optional: additional metrics such as download counts, etc.)

---

## 2. Functional Requirements

### 2.1 Input Handling and Parsing
- **Input:**  
  - Accept a command-line parameter to specify the path to a valid Gemfile.lock file.
- **Parsing Gemfile.lock:**  
  - Either implement a custom parser or leverage Bundler’s lockfile parser to extract:
    - Each gem’s name.
    - Its locked version.
    - (Optionally) Any grouping information if needed.

### 2.2 Data Enrichment via RubyGems.org API
- **API Query:**  
  - For each gem, query the RubyGems.org API endpoint:  
    `https://rubygems.org/api/v1/versions/<gem_name>.json`
- **Data Extraction:**  
  - Filter the returned versions to exclude pre-releases.
  - **Latest Version Data:**  
    - Identify the latest stable version based on the latest `built_at` timestamp.
    - Extract the version number and its release date.
  - **Locked Version Data:**  
    - Find the corresponding entry for the locked version and extract its release date.
    - If the locked version is not present (e.g. if it’s been yanked), flag it with a warning for further review.

### 2.3 Analysis and Calculations
- **Outdated Status Calculation:**  
  - Use Ruby’s `Gem::Version` to compare the locked version with the latest stable version.
  - Mark the gem as “outdated” if the locked version is lower than the latest version.
- **Actively Maintained Status Calculation:**  
  - Define a configurable time threshold (default: 24 months, adjustable via a CLI option).
  - Compare the latest stable version’s release date against the current date.
    - If the latest version’s release date falls within the threshold, mark the gem as “actively maintained.”
    - Otherwise, mark it as not actively maintained.

### 2.4 CSV Export
- **Output CSV File:**  
  - Generate a CSV file where each row represents one gem analyzed.
- **Columns to Include:**  
  - Gem Name  
  - Locked Version  
  - Locked Version Release Date  
  - Latest Version  
  - Latest Release Date  
  - Actively Maintained (yes/no)  
  - Outdated (yes/no)  
  - (Optional: Additional metrics if desired)
- **File Output:**  
  - Allow the output filename/path to be configurable via a command-line option (default: `gem_inspector_report.csv`).

### 2.5 Command-Line Interface (CLI)
- **CLI Options:**  
  - `--input` or `-i`: Path to the Gemfile.lock file.
  - `--output` or `-o`: Path and filename for the CSV report.
  - `--active-threshold` or `-t`: Time threshold in months for “actively maintained” status.
  - `--verbose` or `-v`: Enable verbose logging for debugging.
- **Usage Example:**  
  ```bash
  gem-inspector --input Gemfile.lock --output report.csv --active-threshold 24
  ```

---

## 3. Non-Functional Requirements

### 3.1 Usability and Documentation
- **README and Documentation:**  
  - Document installation steps, usage examples, and configuration options clearly.
  - Provide inline code comments for clarity.
- **CLI Help:**  
  - Include a help message (using OptionParser or similar) that shows usage instructions and available options.

### 3.2 Performance and Robustness
- **API Efficiency:**  
  - Implement rate limiting or batch processing if querying many gems.
- **Error Handling:**  
  - Validate the Gemfile.lock format before processing.
  - Handle network/API errors gracefully and log meaningful error messages.
  - Alert when a gem’s locked version cannot be found in the API response.

### 3.3 Testing
- **Unit Tests:**  
  - Test the Gemfile.lock parser independently.
  - Test the remote enrichment module with sample responses (using mocks or stubs).
  - Test the version comparison logic with various scenarios.
- **Integration Tests:**  
  - Run end-to-end tests on a sample Gemfile.lock to verify CSV output.
- **Test Coverage:**  
  - Ensure high test coverage for both data processing and edge cases.

---

## 4. Architectural Components

### 4.1 Gemfile.lock Parser Module
- **Responsibilities:**  
  - Read the Gemfile.lock and extract gem names and locked versions.
- **Design Considerations:**  
  - Allow future enhancements such as filtering by group or platform.

### 4.2 Data Enrichment Module
- **Responsibilities:**  
  - Send HTTP requests to RubyGems.org API.
  - Parse the JSON response to extract:
    - Latest version number.
    - Latest release (built_at) date.
    - Release date for the locked version.
- **Tools:**  
  - Use Ruby’s Net::HTTP and JSON libraries, or a gem like HTTParty.

### 4.3 Analysis Module
- **Responsibilities:**  
  - Compare versions (using Gem::Version).
  - Determine “outdated” and “actively maintained” statuses.
  - Apply the threshold configuration.
- **Helper Functions:**  
  - Methods for version comparison, date parsing, and threshold checking.

### 4.4 CSV Export Module
- **Responsibilities:**  
  - Use Ruby’s CSV library to output the processed data.
- **Output Format:**  
  - Define headers exactly as per the functional requirements.

### 4.5 CLI Interface Module
- **Responsibilities:**  
  - Parse command-line arguments and pass them to the processing pipeline.
  - Display help and error messages.

---

## 5. Workflow Example

1. **User Invocation:**  
   ```bash
   gem-inspector --input Gemfile.lock --output gem_inspector_report.csv --active-threshold 24
   ```
2. **Processing:**  
   - Read and parse Gemfile.lock.
   - For each gem, query RubyGems.org to obtain version metadata.
   - Identify for each gem:
     - The locked version and its release date.
     - The latest stable version and its release date.
   - Compare versions and calculate:
     - **Outdated:** locked < latest.
     - **Actively Maintained:** if latest release date is within 24 months (or user-specified threshold).
3. **CSV Export:**  
   - Generate a CSV file with headers:
     ```
     Gem Name, Locked Version, Locked Release Date, Latest Version, Latest Release Date, Actively Maintained, Outdated
     ```
   - Write each gem’s data into the CSV.
4. **Output Notification:**  
   - Notify the user of successful export and provide the file location.

---

## 6. LLM Instruction Summary for Developing gem‑inspector

> **LLM Instruction:**  
>  
> *"Develop a Ruby gem named `gem-inspector` that accepts a Gemfile.lock file as input and outputs a CSV report. The CSV must contain the following columns: Gem Name, Locked Version, Locked Release Date, Latest Version, Latest Release Date, Actively Maintained, and Outdated. To achieve this, the gem should:
> 
> 1. Parse the Gemfile.lock to extract each gem name and its locked version.
> 2. For each gem, query RubyGems.org (e.g., via `https://rubygems.org/api/v1/versions/<gem_name>.json`) to obtain version metadata, including the release date (built_at) for each version.
> 3. Determine the latest stable version (ignoring prereleases) and extract its release date.
> 4. Locate the locked version in the fetched data and record its release date.
> 5. Compare the locked version with the latest stable version using Ruby’s Gem::Version to set an ‘outdated’ flag.
> 6. Compare the release date of the latest version with a configurable threshold (default 24 months) to set an ‘actively maintained’ flag.
> 7. Export the results to a CSV file using Ruby’s CSV library.
> 8. Provide a command-line interface that accepts options for the input file, output file, and maintenance threshold.
> 9. Ensure robust error handling for file parsing, network failures, and missing gem data.
> 10. Write unit and integration tests to cover parsing, API retrieval, version comparison, and CSV export.
> 
> Document all code and include a comprehensive README that outlines installation and usage examples."*

---

## 7. Final Considerations

- **Configuration:**  
  - Allow users to specify the maintenance threshold (in months) through CLI options.
- **Extensibility:**  
  - Design the API querying module so it can later be extended to query additional sources (e.g., GitHub repository metrics).
- **Documentation and Tests:**  
  - Maintain clear documentation and high test coverage across all modules.
- **Logging and Error Handling:**  
  - Implement robust logging to help diagnose issues such as network errors or missing version data.
