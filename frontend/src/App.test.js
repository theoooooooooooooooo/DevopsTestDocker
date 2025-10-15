import { render, screen } from '@testing-library/react';
import App from './App';

test('renders application title', () => {
  render(<App />);
  const titleElement = screen.getByText(/Gestion des Salles/i);
  expect(titleElement).toBeInTheDocument();
});

test('renders new room button', () => {
  render(<App />);
  const buttonElement = screen.getByText(/Nouvelle Salle/i);
  expect(buttonElement).toBeInTheDocument();
});