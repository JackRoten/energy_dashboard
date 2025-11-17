import { render, screen, waitFor } from "@testing-library/react";
import FetchData from "./FetchData";

beforeEach(() => {
  global.fetch = vi.fn().mockResolvedValue({
    ok: true,
    json: () => Promise.resolve({ message: "hello world" }),
  });
});

test("loads and displays API data", async () => {
  render(<FetchData />);

  expect(screen.getByText(/loading/i)).toBeInTheDocument();

  await waitFor(() =>
    expect(screen.getByText(/hello world/i)).toBeInTheDocument()
  );
});
