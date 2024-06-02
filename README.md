# Uses the docker/scout-action to scan the Docker image for vulnerabilities and output the results in SARIF format.
- 
        name: Vulnerability Scan with Docker Scout
        id: scan_vulnerabilities
        uses: docker/scout-action@v1
        with:
          command: cves
          image: ${{ steps.meta.outputs.tags }}
          sarif-file: sarif.output.json
          summary: true
  
# Runs a script to analyze the SARIF file for critical and high vulnerabilities.
- 
        name: Analyze CVE Results
        id: analyze_cves
        run: |
          critical_issues=$(jq '[.runs[].results[] | select(.level == "error")] | length' sarif.output.json)
          high_issues=$(jq '[.runs[].results[] | select(.level == "fail")] | length' sarif.output.json)
          echo "Critical issues: $critical_issues"
          echo "High issues: $high_issues"
          if [ "$critical_issues" -ne 0 ] || [ "$high_issues" -ne 0 ]; then
            echo "Critical or high vulnerabilities detected"
            exit 1
          else
            echo "No critical or high vulnerabilities found"
          fi
  
# Logs in to GitHub Container Registry
- 
        name: GHCR Login
        if: ${{ steps.analyze_cves.outcome == 'success' }}
        uses: docker/login-action@v1
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GH_TOKEN }}
  
# Uploading the image to Github
-
        name: Define Metadata for GHCR
        id: meta_ghcr
        if: ${{ steps.analyze_cves.outcome == 'success' }}
        uses: docker/metadata-action@v4
        with:
          images: ghcr.io/${{ github.repository }}
          tags: latest

-
        name: Build and Push Image to GHCR
        if: ${{ steps.analyze_cves.outcome == 'success' }}
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ${{ steps.meta_ghcr.outputs.tags }}
          
# Ran GH Action Workflow
![image](https://github.com/gwifen/zadanie2_docker/assets/107560089/f43b6912-5001-49a4-9364-2bddec9c0c55)

# Package on GitHub
![image](https://github.com/gwifen/zadanie2_docker/assets/107560089/cc73a63b-a4f0-4d95-9790-9860a084c7d2)

# Downloading an Image from DockerHub
![image](https://github.com/gwifen/zadanie2_docker/assets/107560089/a26df864-b7f0-449f-8267-de24bd973318)

# Downloading an Image from GitHub
![image](https://github.com/gwifen/zadanie2_docker/assets/107560089/8522cf54-626a-4fba-9cf2-f97808340c83)


# Link to Repo on DockerHub
https://hub.docker.com/repository/docker/gwifen/zadanie2/general
