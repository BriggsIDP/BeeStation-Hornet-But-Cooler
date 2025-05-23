import { Box, Tooltip } from 'tgui/components';
import { createRenderer } from 'tgui/renderer';
import type { ReactNode } from 'react';

const render = createRenderer();

export const ListOfTooltips = () => {
  const nodes: ReactNode[] = [];

  for (let i = 0; i < 100; i++) {
    nodes.push(
      <Tooltip key={i} content={`This is from tooltip ${i}`} position="bottom">
        <Box as="span" backgroundColor="blue" fontSize="48px" m={1}>
          Tooltip #{i}
        </Box>
      </Tooltip>
    );
  }

  render(<div>{nodes}</div>);
};
