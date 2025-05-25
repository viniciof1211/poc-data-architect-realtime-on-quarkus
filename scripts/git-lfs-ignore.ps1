# Add Maven/Quarkus ignores to .gitignore
Add-Content -Path .gitignore -Value @"
# Maven/Quarkus build artifacts
target/
*.class
*.jar
*.war
*.ear
*.logs
.DS_Store
# IDE files
.vscode/
.idea/
*.iml
# Large files
*.rar
*.exe
"@