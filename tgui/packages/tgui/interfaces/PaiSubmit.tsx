import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, Section, Stack, Tooltip } from '../components';
import { Window } from '../layouts';

type CandidateData = {
  comments: string;
  description: string;
  name: string;
};

type Data = {
  comments: string;
  description: string;
  name: string;
  ready: boolean;
  default_name: string;
  default_description: string;
  default_comments: string;
};
const PAI_DESCRIPTION = `Personal AIs are advanced models
capable of nuanced interaction. They are designed to be used
in a variety of situations, assisting their masters in their
work. They do not possess hands, thus they cannot interact with
equipment or items. While in hologram form, you cannot be
directly killed, but you may be incapacitated.`;

const PAI_RULES = `You are expected to role play to some degree.
Keep in mind: Not entering information may lead to you not being
selected. Press submit to alert pAI cards of your candidacy.`;

export const PaiSubmit = (_) => {
  const { data } = useBackend<Data>();
  const [input, setInput] = useLocalState<CandidateData>('input', {
    name: data.name || '',
    description: data.description || '',
    comments: data.comments || '',
  });

  return (
    <Window width={400} height={460} title="pAI Candidacy Menu">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <DetailsDisplay />
          </Stack.Item>
          <Stack.Item>
            <InputDisplay input={input} setInput={setInput} />
          </Stack.Item>
          <Stack.Item>
            <ButtonsDisplay input={input} setInput={setInput} data={data} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays basic info about playing pAI */
const DetailsDisplay = () => {
  return (
    <Section fill scrollable title="Details">
      <Box color="label">
        {PAI_DESCRIPTION}
        <br />
        <br />
        {PAI_RULES}
      </Box>
    </Section>
  );
};

/** Input boxes for submission details */
const InputDisplay = (props) => {
  const { input, setInput } = props;

  return (
    <Section fill title="Input">
      <Stack fill vertical>
        <Stack.Item>
          <Tooltip content="The name of your pAI.">
            <Box bold color="label">
              Name
            </Box>
            <Input fluid value={input.name} onChange={(e) => setInput({ ...input, name: e.target.value })} />
          </Tooltip>
        </Stack.Item>
        <Stack.Item>
          <Tooltip content="This describes how you will (mis)behave in game.">
            <Box bold color="label">
              Description
            </Box>
            <Input fluid value={input.description} onChange={(e) => setInput({ ...input, description: e.target.value })} />
          </Tooltip>
        </Stack.Item>
        <Stack.Item>
          <Tooltip content="Any other OOC comments about your pAI personality.">
            <Box bold color="label">
              OOC Comments
            </Box>
            <Input fluid value={input.comments} onChange={(e) => setInput({ ...input, comments: e.target.value })} />
          </Tooltip>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/** Gives the user a submit button */
const ButtonsDisplay = (props) => {
  const { act } = useBackend<CandidateData>();
  const { input, setInput, data } = props;
  return (
    <Section fill>
      <Stack>
        <Stack.Item>
          <Button onClick={() => act('save', { candidate: input })} tooltip="Saves your candidate data locally.">
            SAVE
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() => {
              setInput({
                ...input,
                name: data.default_name,
                description: data.default_description,
                comments: data.default_comments,
              });
            }}
            tooltip="Loads saved candidate data, if any.">
            LOAD
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() =>
              act('submit', {
                candidate: input,
              })
            }>
            SUBMIT
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            disabled={!data.ready}
            color="bad"
            onClick={() => act('delete')}
            tooltip="Removes you from the candidate pool">
            DELETE
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
