@echo off
echo "Installing dependencies..."
npm install

echo "Generating Prisma client..."
npx prisma generate

echo "Running database migrations..."
npx prisma migrate dev --name init

echo "Setup complete."
pause
